import AppKit
import CoreGraphics
import MouseCopyPasteCore

private final class MouseEventRouter {
    private let mapping = MouseShortcutMapping()

    func handleEvent(type: CGEventType, event: CGEvent) -> Unmanaged<CGEvent>? {
        guard type == .otherMouseDown else {
            return Unmanaged.passUnretained(event)
        }

        let buttonNumber = event.getIntegerValueField(.mouseEventButtonNumber)
        guard let shortcut = mapping.shortcut(forMouseButton: buttonNumber) else {
            return Unmanaged.passUnretained(event)
        }

        post(shortcut)
        return nil
    }

    private func post(_ shortcut: KeyboardShortcut) {
        let keyCode: CGKeyCode
        switch shortcut {
        case .commandC:
            keyCode = 8
        case .commandV:
            keyCode = 9
        }

        let source = CGEventSource(stateID: .hidSystemState)
        let flags: CGEventFlags = .maskCommand
        let keyDown = CGEvent(keyboardEventSource: source, virtualKey: keyCode, keyDown: true)
        let keyUp = CGEvent(keyboardEventSource: source, virtualKey: keyCode, keyDown: false)
        keyDown?.flags = flags
        keyUp?.flags = flags
        keyDown?.post(tap: .cghidEventTap)
        keyUp?.post(tap: .cghidEventTap)
    }
}

@MainActor
private final class AppDelegate: NSObject, NSApplicationDelegate {
    private let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
    private let router = MouseEventRouter()
    private var eventTap: CFMachPort?
    private var runLoopSource: CFRunLoopSource?
    private var statusMenuItem: NSMenuItem?

    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)
        configureMenu()
        requestAccessibilityIfNeeded()
        startEventTap()
    }

    func applicationWillTerminate(_ notification: Notification) {
        stopEventTap()
    }

    private func configureMenu() {
        if let image = loadStatusIcon() {
            image.size = NSSize(width: 18, height: 18)
            image.isTemplate = true
            statusItem.button?.image = image
            statusItem.button?.imagePosition = .imageOnly
        } else {
            statusItem.button?.title = "CP"
        }
        statusItem.button?.toolTip = "MouseCopyPaste"

        let menu = NSMenu()
        let status = NSMenuItem(title: "Starting...", action: nil, keyEquivalent: "")
        status.isEnabled = false
        statusMenuItem = status
        menu.addItem(status)

        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Request Accessibility Permission", action: #selector(requestPermissionFromMenu), keyEquivalent: ""))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Quit", action: #selector(quit), keyEquivalent: "q"))

        statusItem.menu = menu
    }

    private func loadStatusIcon() -> NSImage? {
        if let image = NSImage(named: "StatusIconTemplate") {
            return image
        }

        let bundleURL = Bundle.module.url(forResource: "StatusIconTemplate", withExtension: "png")
        let mainURL = Bundle.main.url(forResource: "StatusIconTemplate", withExtension: "png")
        return [bundleURL, mainURL].compactMap { $0 }.compactMap(NSImage.init(contentsOf:)).first
    }

    private func requestAccessibilityIfNeeded() {
        guard !AXIsProcessTrusted() else { return }
        let options = ["AXTrustedCheckOptionPrompt": true] as CFDictionary
        AXIsProcessTrustedWithOptions(options)
    }

    @objc private func requestPermissionFromMenu() {
        requestAccessibilityIfNeeded()
        updateStatus()
    }

    @objc private func quit() {
        NSApp.terminate(nil)
    }

    private func startEventTap() {
        let mask = (1 << CGEventType.otherMouseDown.rawValue)
        let refcon = Unmanaged.passUnretained(router).toOpaque()

        eventTap = CGEvent.tapCreate(
            tap: .cgSessionEventTap,
            place: .headInsertEventTap,
            options: .defaultTap,
            eventsOfInterest: CGEventMask(mask),
            callback: { _, type, event, refcon in
                guard let refcon else { return Unmanaged.passUnretained(event) }
                let router = Unmanaged<MouseEventRouter>.fromOpaque(refcon).takeUnretainedValue()
                return router.handleEvent(type: type, event: event)
            },
            userInfo: refcon
        )

        guard let eventTap else {
            updateStatus(message: "Permission needed")
            return
        }

        runLoopSource = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, eventTap, 0)
        if let runLoopSource {
            CFRunLoopAddSource(CFRunLoopGetMain(), runLoopSource, .commonModes)
        }
        CGEvent.tapEnable(tap: eventTap, enable: true)
        updateStatus()
    }

    private func stopEventTap() {
        if let eventTap {
            CGEvent.tapEnable(tap: eventTap, enable: false)
        }
        if let runLoopSource {
            CFRunLoopRemoveSource(CFRunLoopGetMain(), runLoopSource, .commonModes)
        }
        self.runLoopSource = nil
        self.eventTap = nil
    }

    private func updateStatus(message: String? = nil) {
        let trusted = AXIsProcessTrusted()
        let running = eventTap != nil
        let text = message ?? (trusted && running ? "Active: middle=copy, button5=paste" : "Permission needed")
        statusMenuItem?.title = text
        statusItem.button?.toolTip = trusted && running ? "MouseCopyPaste active" : "MouseCopyPaste needs permission"
    }
}

let app = NSApplication.shared
private let delegate = AppDelegate()
app.delegate = delegate
app.run()

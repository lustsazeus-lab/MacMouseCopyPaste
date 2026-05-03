public enum KeyboardShortcut: Equatable, Sendable {
    case commandC
    case commandV
}

public struct MouseShortcutMapping: Sendable {
    public init() {}

    public func shortcut(forMouseButton buttonNumber: Int64) -> KeyboardShortcut? {
        switch buttonNumber {
        case 2:
            return .commandC
        case 4:
            return .commandV
        default:
            return nil
        }
    }
}

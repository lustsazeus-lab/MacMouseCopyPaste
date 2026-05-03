// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "MouseCopyPaste",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .library(name: "MouseCopyPasteCore", targets: ["MouseCopyPasteCore"]),
        .executable(name: "MouseCopyPaste", targets: ["MouseCopyPasteApp"])
    ],
    targets: [
        .target(name: "MouseCopyPasteCore"),
        .executableTarget(
            name: "MouseCopyPasteApp",
            dependencies: ["MouseCopyPasteCore"],
            linkerSettings: [
                .linkedFramework("AppKit"),
                .linkedFramework("CoreGraphics")
            ]
        )
    ]
)

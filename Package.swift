// swift-tools-version:6.0
import PackageDescription

let package = Package(
    name: "CursorSpotlight",
    defaultLocalization: "en",
    platforms: [
        .macOS(.v13),
    ],
    products: [
        .executable(name: "CursorSpotlight", targets: ["CursorSpotlight"]),
    ],
    dependencies: [
        .package(url: "https://github.com/soffes/HotKey", from: "0.2.0"),
    ],
    targets: [
        .executableTarget(
            name: "CursorSpotlight",
            dependencies: ["HotKey"],
            path: "Sources/CursorSpotlight",
            swiftSettings: [
                .swiftLanguageMode(.v5),
            ]
        ),
        .testTarget(
            name: "CursorSpotlightTests",
            dependencies: ["CursorSpotlight", "HotKey"],
            path: "Tests/CursorSpotlightTests",
            swiftSettings: [
                .swiftLanguageMode(.v5),
            ]
        ),
    ]
)

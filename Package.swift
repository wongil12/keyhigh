// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "KeyHigh",
    platforms: [
        .macOS(.v13)
    ],
    targets: [
        .executableTarget(
            name: "KeyHigh",
            path: "Sources/KeyHigh",
            resources: [
                .copy("Resources")
            ]
        )
    ]
)

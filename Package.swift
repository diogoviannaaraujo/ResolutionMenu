// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "ResolutionMenu",
    platforms: [
        .macOS(.v14) // Target modern macOS for latest SwiftUI features
    ],
    products: [
        .executable(
            name: "ResolutionMenu",
            targets: ["ResolutionMenu"]
        )
    ],
    targets: [
        .executableTarget(
            name: "ResolutionMenu",
            dependencies: []
        )
    ]
)

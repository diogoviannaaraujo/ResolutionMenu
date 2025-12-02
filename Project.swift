import ProjectDescription

let project = Project(
    name: "ResolutionMenu",
    targets: [
        .target(
            name: "ResolutionMenu",
            destinations: .macOS,
            product: .app,
            bundleId: "com.diogoviannaaraujo.ResolutionMenu",
            deploymentTargets: .macOS("14.0"),
            infoPlist: .extendingDefault(with: [
                "LSUIElement": true,
                "CFBundleDisplayName": "Resolution Menu",
                "CFBundleShortVersionString": "1.0",
                "CFBundleVersion": "1",
            ]),
            sources: ["Sources/ResolutionMenu/**"],
            resources: [
                "Resources/AppIcon.icon",
            ],
            dependencies: []
        )
    ]
)

// swift-tools-version: 6.2
import PackageDescription

let package = Package(
    name: "TasksFeature",
    defaultLocalization: "es",
    platforms: [.iOS(.v26), .macOS(.v26), .visionOS(.v26)],
    products: [
        .library(name: "TasksFeature", targets: ["TasksFeature"])
    ],
    dependencies: [
        .package(path: "../WaypointCore"),
        .package(path: "../DesignSystem")
    ],
    targets: [
        .target(
            name: "TasksFeature",
            dependencies: [
                "WaypointCore",
                .product(name: "DesignSystem", package: "DesignSystem"),
            ],
            swiftSettings: [.defaultIsolation(MainActor.self)]
        )
    ]
)

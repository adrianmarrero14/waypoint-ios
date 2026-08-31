// swift-tools-version: 6.2
import PackageDescription

let package = Package(
    name: "HabitsFeature",
    defaultLocalization: "es",
    platforms: [.iOS(.v26), .macOS(.v26), .visionOS(.v26)],
    products: [
        .library(name: "HabitsFeature", targets: ["HabitsFeature"])
    ],
    dependencies: [
        .package(path: "../WaypointCore"),
        .package(path: "../DesignSystem")
    ],
    targets: [
        .target(
            name: "HabitsFeature",
            dependencies: [
                "WaypointCore",
                .product(name: "DesignSystem", package: "DesignSystem"),
            ],
            swiftSettings: [.defaultIsolation(MainActor.self)]
        )
    ]
)

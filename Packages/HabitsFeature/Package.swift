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
        .package(path: "../WaypointCore")
    ],
    targets: [
        .target(
            name: "HabitsFeature",
            dependencies: ["WaypointCore"],
            swiftSettings: [.defaultIsolation(MainActor.self)]
        )
    ]
)

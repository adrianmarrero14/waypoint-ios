// swift-tools-version: 6.2
import PackageDescription

let package = Package(
    name: "WaypointFeature",
    defaultLocalization: "es",
    platforms: [.iOS(.v26), .macOS(.v26), .visionOS(.v26)],
    products: [
        .library(name: "WaypointFeature", targets: ["WaypointFeature"])
    ],
    dependencies: [
        .package(path: "../WaypointCore"),
        .package(path: "../DesignSystem")
    ],
    targets: [
        .target(
            name: "WaypointFeature",
            dependencies: [
                "WaypointCore",
                .product(name: "DesignSystem", package: "DesignSystem"),
            ],
            swiftSettings: [.defaultIsolation(MainActor.self)]
        )
    ]
)

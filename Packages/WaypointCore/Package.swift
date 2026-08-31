// swift-tools-version: 6.2
import PackageDescription

let package = Package(
    name: "WaypointCore",
    defaultLocalization: "es",
    platforms: [.iOS(.v26), .macOS(.v26), .visionOS(.v26)],
    products: [
        .library(name: "WaypointCore", targets: ["WaypointCore"])
    ],
    targets: [
        .target(
            name: "WaypointCore",
            swiftSettings: [.defaultIsolation(MainActor.self)]
        )
    ]
)

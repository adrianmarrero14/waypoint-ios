// swift-tools-version: 6.2
import PackageDescription

let package = Package(
    name: "DesignSystem",
    defaultLocalization: "es",
    platforms: [.iOS(.v26), .macOS(.v26), .visionOS(.v26)],
    products: [
        .library(name: "DesignSystem", targets: ["DesignSystem"])
    ],
    targets: [
        .target(
            name: "DesignSystem",
            resources: [.copy("Resources/Fonts")],
            swiftSettings: [.defaultIsolation(MainActor.self)]
        )
    ]
)

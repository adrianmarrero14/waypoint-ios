// swift-tools-version: 6.2
import PackageDescription

let package = Package(
    name: "AuthFeature",
    defaultLocalization: "es",
    platforms: [.iOS(.v26), .macOS(.v26), .visionOS(.v26)],
    products: [
        .library(name: "AuthFeature", targets: ["AuthFeature"])
    ],
    dependencies: [
        .package(path: "../WaypointCore"),
        .package(path: "../DesignSystem"),
        .package(url: "https://github.com/supabase/supabase-swift.git", from: "2.55.0")
    ],
    targets: [
        .target(
            name: "AuthFeature",
            dependencies: [
                "WaypointCore",
                .product(name: "DesignSystem", package: "DesignSystem"),
                .product(name: "Auth", package: "supabase-swift"),
                .product(name: "PostgREST", package: "supabase-swift"),
            ],
            resources: [.process("Resources")],
            swiftSettings: [.defaultIsolation(MainActor.self)]
        )
    ]
)

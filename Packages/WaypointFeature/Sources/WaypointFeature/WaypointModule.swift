import SwiftUI
import WaypointCore

public enum WaypointModule {
    public static let descriptor = ModuleDescriptor(
        id: "waypoint",
        name: LocalizedStringResource(
            "module.waypoint.name",
            bundle: .atURL(Bundle.module.bundleURL)
        ),
        systemImage: "paperplane.circle",
        makeRootView: { AnyView(WaypointRootView()) }
    )
}

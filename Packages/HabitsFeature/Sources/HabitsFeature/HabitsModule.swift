import SwiftUI
import WaypointCore

public enum HabitsModule {
    public static let descriptor = ModuleDescriptor(
        id: "habits",
        name: LocalizedStringResource(
            "module.habits.name",
            bundle: .atURL(Bundle.module.bundleURL)
        ),
        systemImage: "checkmark.circle",
        makeRootView: { AnyView(HabitsRootView()) }
    )
}

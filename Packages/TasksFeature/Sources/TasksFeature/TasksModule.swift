import SwiftUI
import WaypointCore

public enum TasksModule {
    public static let descriptor = ModuleDescriptor(
        id: "tasks",
        name: LocalizedStringResource(
            "module.tasks.name",
            bundle: .atURL(Bundle.module.bundleURL)
        ),
        systemImage: "checklist",
        makeRootView: { AnyView(TasksRootView()) }
    )
}

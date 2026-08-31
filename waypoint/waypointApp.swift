import DesignSystem
import SwiftUI
import WaypointCore

@main
struct waypointApp: App {
    @State private var moduleSettings = ModuleSettings()

    init() {
        WaypointAppearance.apply()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(moduleSettings)
        }
    }
}

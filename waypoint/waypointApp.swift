import SwiftUI
import WaypointCore

@main
struct waypointApp: App {
    @State private var moduleSettings = ModuleSettings()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(moduleSettings)
        }
    }
}

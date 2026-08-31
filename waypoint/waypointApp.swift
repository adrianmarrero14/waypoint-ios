import DesignSystem
import SwiftUI
import WaypointCore

@main
struct waypointApp: App {
    @State private var moduleSettings = ModuleSettings()
    @State private var languageSettings = LanguageSettings()
    @State private var appearanceSettings = AppearanceSettings()

    init() {
        WaypointAppearance.apply()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(moduleSettings)
                .environment(languageSettings)
                .environment(appearanceSettings)
        }
    }
}

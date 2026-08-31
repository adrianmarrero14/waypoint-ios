import SwiftUI
import WaypointCore

struct ContentView: View {
    @Environment(ModuleSettings.self) private var moduleSettings

    var body: some View {
        TabView {
            ForEach(ModuleRegistry.all.filter { moduleSettings.isEnabled($0.id) }) { module in
                Tab {
                    module.makeRootView()
                } label: {
                    Label {
                        Text(module.name)
                    } icon: {
                        Image(systemName: module.systemImage)
                    }
                }
            }
            Tab {
                SettingsView()
            } label: {
                Label("settings.tab.title", systemImage: "gearshape")
            }
        }
    }
}

#Preview {
    ContentView()
        .environment(ModuleSettings())
}

import SwiftUI
import WaypointCore

struct SettingsView: View {
    @Environment(ModuleSettings.self) private var moduleSettings

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    ForEach(ModuleRegistry.all) { module in
                        Toggle(isOn: Binding(
                            get: { moduleSettings.isEnabled(module.id) },
                            set: { moduleSettings.setEnabled($0, moduleID: module.id) }
                        )) {
                            Label {
                                Text(module.name)
                            } icon: {
                                Image(systemName: module.systemImage)
                            }
                        }
                    }
                } header: {
                    Text("settings.modules.header")
                } footer: {
                    Text("settings.modules.footer")
                }
            }
            .navigationTitle(Text("settings.tab.title"))
        }
    }
}

#Preview {
    SettingsView()
        .environment(ModuleSettings())
}

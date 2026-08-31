import DesignSystem
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
                                    .font(.wpBody)
                                    .foregroundStyle(Color.wpDeepNavy)
                            } icon: {
                                Image(systemName: module.systemImage)
                                    .foregroundStyle(Color.wpOceanBlue)
                            }
                        }
                        .tint(Color.wpOceanBlue)
                    }
                } header: {
                    Text("settings.modules.header")
                        .waypointLabelStyle()
                } footer: {
                    Text("settings.modules.footer")
                        .font(.wpCaption)
                        .foregroundStyle(Color.wpTextTertiary)
                }
            }
            .scrollContentBackground(.hidden)
            .background(Color.wpFoam)
            .navigationTitle(Text("settings.tab.title"))
        }
    }
}

#Preview {
    SettingsView()
        .environment(ModuleSettings())
}

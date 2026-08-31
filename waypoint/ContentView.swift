import DesignSystem
import SwiftUI
import WaypointCore

struct ContentView: View {
    @Environment(ModuleSettings.self) private var moduleSettings
    @Environment(LanguageSettings.self) private var languageSettings
    @Environment(AppearanceSettings.self) private var appearanceSettings

    var body: some View {
        TabView {
            ForEach(ModuleRegistry.all.filter { moduleSettings.isEnabled($0.id) }) { module in
                Tab {
                    module.makeRootView()
                } label: {
                    Label {
                        Text(localizedName(of: module))
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
        .tint(Color.wpOceanBlue)
        .environment(\.locale, languageSettings.localeOverride ?? .autoupdatingCurrent)
        .id(languageSettings.language)
        .preferredColorScheme(appearanceSettings.colorScheme)
    }

    /// LocalizedStringResource resolves against the app's preferred languages,
    /// not the environment locale, so the override must be set on the resource.
    private func localizedName(of module: ModuleDescriptor) -> LocalizedStringResource {
        var name = module.name
        if let locale = languageSettings.localeOverride {
            name.locale = locale
        }
        return name
    }
}

#Preview {
    ContentView()
        .environment(ModuleSettings())
        .environment(LanguageSettings())
        .environment(AppearanceSettings())
}

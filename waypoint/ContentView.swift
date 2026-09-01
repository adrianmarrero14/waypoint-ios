import AuthFeature
import DesignSystem
import SwiftUI
import WaypointCore

struct ContentView: View {
    @Environment(ModuleSettings.self) private var moduleSettings
    @Environment(LanguageSettings.self) private var languageSettings
    @Environment(AppearanceSettings.self) private var appearanceSettings
    @Environment(AppRouter.self) private var router
    @Environment(NotificationScheduler.self) private var notificationScheduler
    @Environment(AppLockManager.self) private var appLockManager

    @AppStorage("waypoint.hasSeenNotificationOnboarding")
    private var hasSeenNotificationOnboarding = false
    @State private var isNotificationOnboardingPresented = false

    var body: some View {
        TabView(selection: Bindable(router).selectedModuleID) {
            ForEach(ModuleRegistry.all.filter { moduleSettings.isEnabled($0.id) }) { module in
                Tab(value: module.id) {
                    module.makeRootView()
                } label: {
                    Label {
                        Text(localizedName(of: module))
                    } icon: {
                        Image(systemName: module.systemImage)
                    }
                }
            }
            Tab(value: "settings") {
                SettingsView()
            } label: {
                Label("settings.tab.title", systemImage: "gearshape")
            }
        }
        .overlay {
            if appLockManager.isLocked {
                AppLockView()
            }
        }
        .tint(Color.wpOceanBlue)
        .environment(\.locale, languageSettings.localeOverride ?? .autoupdatingCurrent)
        .id(languageSettings.language)
        .preferredColorScheme(appearanceSettings.colorScheme)
        .task {
            if !hasSeenNotificationOnboarding {
                hasSeenNotificationOnboarding = true
                isNotificationOnboardingPresented = true
            }
        }
        .sheet(isPresented: $isNotificationOnboardingPresented) {
            NotificationOnboardingSheet(scheduler: notificationScheduler)
                .presentationDetents([.medium])
        }
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
        .environment(AppRouter())
        .environment(NotificationScheduler())
        .environment(AppLockSettings())
        .environment(AppLockManager())
        .environment(SessionStore(config: SupabaseEnvironment.config))
}

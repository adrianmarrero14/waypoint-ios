import AuthFeature
import DesignSystem
import LocalAuthentication
import SwiftUI
import WaypointCore

struct SettingsView: View {
    @Environment(ModuleSettings.self) private var moduleSettings
    @Environment(LanguageSettings.self) private var languageSettings
    @Environment(AppearanceSettings.self) private var appearanceSettings
    @Environment(AppLockSettings.self) private var appLockSettings

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    AccountSectionView()
                } header: {
                    Text("settings.account.header")
                        .waypointLabelStyle()
                }

                Section {
                    ForEach(ModuleRegistry.all) { module in
                        Toggle(isOn: Binding(
                            get: { moduleSettings.isEnabled(module.id) },
                            set: { moduleSettings.setEnabled($0, moduleID: module.id) }
                        )) {
                            Label {
                                Text(localizedName(of: module))
                                    .font(.wpBody)
                                    .foregroundStyle(Color.wpTextPrimary)
                            } icon: {
                                Image(systemName: module.systemImage)
                                    .foregroundStyle(Color.wpLabelAccent)
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

                Section {
                    Picker(selection: Binding(
                        get: { languageSettings.language },
                        set: { languageSettings.language = $0 }
                    )) {
                        Text("settings.language.system")
                            .tag(LanguageSettings.AppLanguage.system)
                        Text(verbatim: "Español")
                            .tag(LanguageSettings.AppLanguage.spanish)
                        Text(verbatim: "English")
                            .tag(LanguageSettings.AppLanguage.english)
                    } label: {
                        Label {
                            Text("settings.language.title")
                                .font(.wpBody)
                                .foregroundStyle(Color.wpTextPrimary)
                        } icon: {
                            Image(systemName: "globe")
                                .foregroundStyle(Color.wpLabelAccent)
                        }
                    }
                    .tint(Color.wpTextSecondary)
                } header: {
                    Text("settings.language.header")
                        .waypointLabelStyle()
                }

                Section {
                    Picker(selection: Binding(
                        get: { appearanceSettings.theme },
                        set: { appearanceSettings.theme = $0 }
                    )) {
                        Text("settings.appearance.system")
                            .tag(AppearanceSettings.Theme.system)
                        Text("settings.appearance.light")
                            .tag(AppearanceSettings.Theme.light)
                        Text("settings.appearance.dark")
                            .tag(AppearanceSettings.Theme.dark)
                    } label: {
                        Label {
                            Text("settings.appearance.title")
                                .font(.wpBody)
                                .foregroundStyle(Color.wpTextPrimary)
                        } icon: {
                            Image(systemName: "circle.lefthalf.filled")
                                .foregroundStyle(Color.wpLabelAccent)
                        }
                    }
                    .tint(Color.wpTextSecondary)
                } header: {
                    Text("settings.appearance.header")
                        .waypointLabelStyle()
                }

                Section {
                    Toggle(isOn: Binding(
                        get: { appLockSettings.isEnabled },
                        set: { setAppLockEnabled($0) }
                    )) {
                        Label {
                            Text("settings.security.appLock.title")
                                .font(.wpBody)
                                .foregroundStyle(Color.wpTextPrimary)
                        } icon: {
                            Image(systemName: "faceid")
                                .foregroundStyle(Color.wpLabelAccent)
                        }
                    }
                    .tint(Color.wpOceanBlue)
                    .disabled(!AppLockManager.canAuthenticate())
                } header: {
                    Text("settings.security.header")
                        .waypointLabelStyle()
                } footer: {
                    Text("settings.security.appLock.footer")
                        .font(.wpCaption)
                        .foregroundStyle(Color.wpTextTertiary)
                }
            }
            .scrollContentBackground(.hidden)
            .background(Color.wpBackground)
            .navigationTitle(Text("settings.tab.title"))
        }
    }

    /// Verifies the user's identity once before enabling the lock, so the
    /// toggle can't be flipped on by someone who couldn't unlock it later.
    private func setAppLockEnabled(_ enabled: Bool) {
        guard enabled else {
            appLockSettings.isEnabled = false
            return
        }
        Task {
            let context = LAContext()
            guard context.canEvaluatePolicy(.deviceOwnerAuthentication, error: nil) else { return }
            let reason = String(localized: "applock.reason")
            if (try? await context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: reason)) == true {
                appLockSettings.isEnabled = true
            }
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
    SettingsView()
        .environment(ModuleSettings())
        .environment(LanguageSettings())
        .environment(AppearanceSettings())
        .environment(AppLockSettings())
        .environment(SessionStore(config: SupabaseEnvironment.config))
}

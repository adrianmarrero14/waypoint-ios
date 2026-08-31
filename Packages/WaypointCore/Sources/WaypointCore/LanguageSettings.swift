import Foundation
import Observation

/// The user's in-app language choice, persisted in UserDefaults.
/// `system` follows the device language; the others override the UI locale.
@Observable
public final class LanguageSettings {
    public enum AppLanguage: String, CaseIterable {
        case system
        case spanish = "es"
        case english = "en"
    }

    private static let languageKey = "waypoint.appLanguage"

    private let defaults: UserDefaults

    public var language: AppLanguage {
        didSet {
            defaults.set(language.rawValue, forKey: Self.languageKey)
        }
    }

    /// Locale to inject into the SwiftUI environment, or nil to follow the system.
    public var localeOverride: Locale? {
        switch language {
        case .system: nil
        case .spanish: Locale(identifier: "es")
        case .english: Locale(identifier: "en")
        }
    }

    public init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        let stored = defaults.string(forKey: Self.languageKey) ?? ""
        self.language = AppLanguage(rawValue: stored) ?? .system
    }
}

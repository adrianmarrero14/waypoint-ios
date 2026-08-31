import SwiftUI
import Observation

/// The user's in-app theme choice, persisted in UserDefaults.
/// `system` follows the device appearance; the others force light or dark.
@Observable
public final class AppearanceSettings {
    public enum Theme: String, CaseIterable {
        case system
        case light
        case dark
    }

    private static let themeKey = "waypoint.appTheme"

    private let defaults: UserDefaults

    public var theme: Theme {
        didSet {
            defaults.set(theme.rawValue, forKey: Self.themeKey)
        }
    }

    /// Color scheme to force via `preferredColorScheme`, or nil to follow the system.
    public var colorScheme: ColorScheme? {
        switch theme {
        case .system: nil
        case .light: .light
        case .dark: .dark
        }
    }

    public init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        let stored = defaults.string(forKey: Self.themeKey) ?? ""
        self.theme = Theme(rawValue: stored) ?? .system
    }
}

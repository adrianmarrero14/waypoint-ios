import Foundation
import Observation

/// Whether the app requires biometric/passcode unlock on launch and when
/// returning from the background, persisted in UserDefaults. Independent from
/// any account session.
@Observable
public final class AppLockSettings {
    private static let enabledKey = "waypoint.appLockEnabled"

    private let defaults: UserDefaults

    public var isEnabled: Bool {
        didSet {
            defaults.set(isEnabled, forKey: Self.enabledKey)
        }
    }

    public init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        self.isEnabled = defaults.bool(forKey: Self.enabledKey)
    }
}

import Foundation
import Observation

/// Per-user module enablement, persisted in UserDefaults.
/// Stores the *disabled* set so that new modules default to enabled.
@Observable
public final class ModuleSettings {
    private static let disabledKey = "waypoint.disabledModuleIDs"

    private let defaults: UserDefaults

    private var disabledModuleIDs: Set<String> {
        didSet {
            defaults.set(Array(disabledModuleIDs).sorted(), forKey: Self.disabledKey)
        }
    }

    public init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        let stored = defaults.stringArray(forKey: Self.disabledKey) ?? []
        self.disabledModuleIDs = Set(stored)
    }

    public func isEnabled(_ moduleID: String) -> Bool {
        !disabledModuleIDs.contains(moduleID)
    }

    public func setEnabled(_ enabled: Bool, moduleID: String) {
        if enabled {
            disabledModuleIDs.remove(moduleID)
        } else {
            disabledModuleIDs.insert(moduleID)
        }
    }
}

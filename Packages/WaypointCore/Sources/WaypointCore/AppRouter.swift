import Observation

/// App-level navigation state shared between the app target (tab selection,
/// notification handling) and feature modules, keeping `ModuleRegistry` generic.
@Observable
public final class AppRouter {
    /// Drives the root `TabView` selection; matches `ModuleDescriptor.id`.
    public var selectedModuleID: String?
    /// Set when a deep link (e.g. a notification tap) asks the Waypoint module
    /// to present its quick-add sheet. The module resets it after presenting.
    public var pendingWaypointQuickAdd = false

    public init() {}

    /// Route from a notification tap straight into the quick-add sheet.
    public func openWaypointQuickAdd() {
        selectedModuleID = "waypoint"
        pendingWaypointQuickAdd = true
    }
}

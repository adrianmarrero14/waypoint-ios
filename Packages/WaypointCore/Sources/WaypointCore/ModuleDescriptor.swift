import SwiftUI

/// Describes a Waypoint feature module: identity, presentation metadata and its root view.
public struct ModuleDescriptor: Identifiable {
    /// Stable identifier, also used as the persistence key for enablement. Never change it.
    public let id: String
    public let name: LocalizedStringResource
    public let systemImage: String
    public let makeRootView: @MainActor () -> AnyView

    public init(
        id: String,
        name: LocalizedStringResource,
        systemImage: String,
        makeRootView: @escaping @MainActor () -> AnyView
    ) {
        self.id = id
        self.name = name
        self.systemImage = systemImage
        self.makeRootView = makeRootView
    }
}

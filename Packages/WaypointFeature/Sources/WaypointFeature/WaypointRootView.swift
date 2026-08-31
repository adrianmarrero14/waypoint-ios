import DesignSystem
import SwiftUI

struct WaypointRootView: View {
    var body: some View {
        NavigationStack {
            WaypointEmptyState(
                title: Text("module.waypoint.name", bundle: .module),
                message: Text("module.waypoint.placeholder", bundle: .module),
                systemImage: "paperplane.circle"
            )
            .navigationTitle(Text("module.waypoint.name", bundle: .module))
        }
    }
}

#Preview {
    WaypointRootView()
}

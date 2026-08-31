import DesignSystem
import SwiftUI

struct HabitsRootView: View {
    var body: some View {
        NavigationStack {
            WaypointEmptyState(
                title: Text("module.habits.name", bundle: .module),
                message: Text("module.habits.placeholder", bundle: .module),
                systemImage: "checkmark.circle"
            )
            .navigationTitle(Text("module.habits.name", bundle: .module))
        }
    }
}

#Preview {
    HabitsRootView()
}

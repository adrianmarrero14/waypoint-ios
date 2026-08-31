import DesignSystem
import SwiftUI

struct TasksRootView: View {
    var body: some View {
        NavigationStack {
            WaypointEmptyState(
                title: Text("module.tasks.name", bundle: .module),
                message: Text("module.tasks.placeholder", bundle: .module),
                systemImage: "checklist"
            )
            .navigationTitle(Text("module.tasks.name", bundle: .module))
        }
    }
}

#Preview {
    TasksRootView()
}

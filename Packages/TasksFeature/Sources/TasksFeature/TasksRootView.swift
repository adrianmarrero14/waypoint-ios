import SwiftUI

struct TasksRootView: View {
    var body: some View {
        NavigationStack {
            ContentUnavailableView(
                String(localized: "module.tasks.name", bundle: .module),
                systemImage: "checklist",
                description: Text("module.tasks.placeholder", bundle: .module)
            )
            .navigationTitle(Text("module.tasks.name", bundle: .module))
        }
    }
}

#Preview {
    TasksRootView()
}

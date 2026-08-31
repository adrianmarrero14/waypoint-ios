import SwiftUI

struct HabitsRootView: View {
    var body: some View {
        NavigationStack {
            ContentUnavailableView(
                String(localized: "module.habits.name", bundle: .module),
                systemImage: "checkmark.circle",
                description: Text("module.habits.placeholder", bundle: .module)
            )
            .navigationTitle(Text("module.habits.name", bundle: .module))
        }
    }
}

#Preview {
    HabitsRootView()
}

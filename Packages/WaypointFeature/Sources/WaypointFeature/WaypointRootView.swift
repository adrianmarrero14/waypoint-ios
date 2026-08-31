import DesignSystem
import SwiftUI
import WaypointCore

struct WaypointRootView: View {
    @Environment(AppRouter.self) private var router
    @State private var isQuickAddPresented = false

    var body: some View {
        NavigationStack {
            YearView()
                .navigationTitle(Text("module.waypoint.name", bundle: .module))
                .toolbar {
                    ToolbarItem(placement: .primaryAction) {
                        AddEntryButton { isQuickAddPresented = true }
                    }
                }
        }
        .sheet(isPresented: $isQuickAddPresented) {
            QuickAddView()
        }
        .onChange(of: router.pendingWaypointQuickAdd, initial: true) { _, pending in
            if pending {
                router.pendingWaypointQuickAdd = false
                isQuickAddPresented = true
            }
        }
    }
}

#Preview {
    WaypointRootView()
        .environment(AppRouter())
        .modelContainer(PreviewData.makeContainer())
}

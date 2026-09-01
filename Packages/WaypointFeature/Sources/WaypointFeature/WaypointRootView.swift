import DesignSystem
import SwiftUI
import WaypointCore

struct WaypointRootView: View {
    @Environment(AppRouter.self) private var router
    @Environment(WaveStore.self) private var waveStore
    @State private var isQuickAddPresented = false

    var body: some View {
        NavigationStack {
            // .id forces the query predicates to rebuild when the session changes.
            YearView(ownerID: waveStore.currentUserID)
                .id(waveStore.currentUserID)
                .navigationTitle(Text("module.waypoint.name", bundle: .module))
                .toolbar {
                    ToolbarItem(placement: .primaryAction) {
                        AddWaveButton { isQuickAddPresented = true }
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
    let container = PreviewData.makeContainer()
    WaypointRootView()
        .environment(AppRouter())
        .modelContainer(container)
        .environment(PreviewData.makeStore(container: container))
}

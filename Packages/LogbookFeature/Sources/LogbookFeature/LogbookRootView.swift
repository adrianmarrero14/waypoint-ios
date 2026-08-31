import DesignSystem
import SwiftUI

struct LogbookRootView: View {
    var body: some View {
        NavigationStack {
            WaypointEmptyState(
                title: Text("module.logbook.name", bundle: .module),
                message: Text("module.logbook.placeholder", bundle: .module),
                systemImage: "book.closed"
            )
            .navigationTitle(Text("module.logbook.name", bundle: .module))
        }
    }
}

#Preview {
    LogbookRootView()
}

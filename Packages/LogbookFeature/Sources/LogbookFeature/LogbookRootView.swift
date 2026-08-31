import SwiftUI

struct LogbookRootView: View {
    var body: some View {
        NavigationStack {
            ContentUnavailableView(
                String(localized: "module.logbook.name", bundle: .module),
                systemImage: "book.closed",
                description: Text("module.logbook.placeholder", bundle: .module)
            )
            .navigationTitle(Text("module.logbook.name", bundle: .module))
        }
    }
}

#Preview {
    LogbookRootView()
}

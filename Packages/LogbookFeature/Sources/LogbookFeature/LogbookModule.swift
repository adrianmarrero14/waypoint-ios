import SwiftUI
import WaypointCore

public enum LogbookModule {
    public static let descriptor = ModuleDescriptor(
        id: "logbook",
        name: LocalizedStringResource(
            "module.logbook.name",
            bundle: .atURL(Bundle.module.bundleURL)
        ),
        systemImage: "book.closed",
        makeRootView: { AnyView(LogbookRootView()) }
    )
}

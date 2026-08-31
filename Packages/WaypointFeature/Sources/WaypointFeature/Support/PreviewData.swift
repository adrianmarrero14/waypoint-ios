import Foundation
import SwiftData
import WaypointCore

/// In-memory container with sample entries for previews.
enum PreviewData {
    static func makeContainer() -> ModelContainer {
        let config = ModelConfiguration(isStoredInMemoryOnly: true, cloudKitDatabase: .none)
        let container = try! ModelContainer(for: Entry.self, configurations: config)
        SampleData.seed(context: container.mainContext)
        return container
    }
}

import Foundation
import SwiftData
import WaypointCore

/// In-memory container with sample waves for previews.
enum PreviewData {
    static func makeContainer() -> ModelContainer {
        let config = ModelConfiguration(isStoredInMemoryOnly: true, cloudKitDatabase: .none)
        let container = try! ModelContainer(for: Wave.self, configurations: config)
        SampleData.seed(context: container.mainContext)
        return container
    }

    static func makeStore(container: ModelContainer) -> WaveStore {
        WaveStore(modelContext: container.mainContext)
    }
}

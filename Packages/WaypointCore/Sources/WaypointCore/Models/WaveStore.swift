import Foundation
import Observation
import SwiftData

/// Single entry point for all wave mutations. Stamps `updatedAt` on every
/// change, saves explicitly (sync reads persisted state), and notifies the
/// sync engine through `onLocalChange`.
@Observable
public final class WaveStore {
    public private(set) var currentUserID: UUID?

    /// Fired after every persisted local mutation; the app wires this to the
    /// sync engine's debounced trigger.
    @ObservationIgnored public var onLocalChange: (() -> Void)?

    private let modelContext: ModelContext

    public init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    public func setCurrentUser(_ id: UUID?) {
        currentUserID = id
    }

    public func createWave(text: String, date: Date) {
        let wave = Wave(text: text, date: date, ownerID: currentUserID)
        modelContext.insert(wave)
        persistAndNotify()
    }

    public func update(_ wave: Wave, text: String, date: Date) {
        wave.text = text
        wave.date = date
        wave.updatedAt = .now
        persistAndNotify()
    }

    /// Soft delete: the tombstone stays local until the server acknowledges it.
    public func delete(_ wave: Wave) {
        wave.deletedAt = .now
        wave.updatedAt = .now
        persistAndNotify()
    }

    /// Assigns unowned waves to the given account and marks them dirty so the
    /// next push uploads them. Called once on sign-in.
    public func adoptOrphans(ownerID: UUID) {
        let orphans = (try? modelContext.fetch(
            FetchDescriptor<Wave>(predicate: #Predicate { $0.ownerID == nil })
        )) ?? []
        guard !orphans.isEmpty else { return }
        for wave in orphans {
            wave.ownerID = ownerID
            wave.updatedAt = .now
            wave.syncedAt = nil
        }
        persistAndNotify()
    }

    /// Hard-deletes tombstones that the server has already acknowledged.
    public func purgeSyncedTombstones(olderThan days: Int = 30) {
        let cutoff = Calendar.current.date(byAdding: .day, value: -days, to: .now) ?? .distantPast
        let stale = (try? modelContext.fetch(
            FetchDescriptor<Wave>(predicate: #Predicate {
                $0.deletedAt != nil && $0.syncedAt != nil && $0.updatedAt < cutoff
            })
        )) ?? []
        guard !stale.isEmpty else { return }
        for wave in stale {
            modelContext.delete(wave)
        }
        try? modelContext.save()
    }

    private func persistAndNotify() {
        try? modelContext.save()
        onLocalChange?()
    }
}

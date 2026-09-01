import Foundation
import SwiftData

/// A single journal wave. Year/Month/Week grouping is derived from `date`
/// with `Calendar` — never modeled as separate entities.
///
/// CloudKit-compatible: every stored property has a default value, no unique
/// constraints, no required relationships. Future additions (photos, tags)
/// must be optional properties or optional relationships so the schema stays
/// lightweight-migratable. Logical uniqueness of `id` is enforced by the sync
/// engine (fetch-by-id upsert), not by the schema.
@Model
public final class Wave {
    /// Client-generated identity; primary key on the server.
    public var id: UUID = UUID()
    /// Free-form text of the wave.
    public var text: String = ""
    /// The day the wave refers to (user-editable, defaults to today).
    public var date: Date = Date.now
    /// When the wave was written.
    public var createdAt: Date = Date.now
    /// Bumped on every local mutation; the last-write-wins clock for sync.
    public var updatedAt: Date = Date.now
    /// Account that owns the wave; nil = unowned/local-only.
    public var ownerID: UUID? = nil
    /// Soft-delete tombstone so deletions can be pushed to the server.
    public var deletedAt: Date? = nil
    /// The `updatedAt` value last acknowledged by the server. Local-only
    /// bookkeeping (never pushed); dirty iff nil or older than `updatedAt`.
    public var syncedAt: Date? = nil

    public init(
        id: UUID = UUID(),
        text: String = "",
        date: Date = .now,
        createdAt: Date = .now,
        updatedAt: Date = .now,
        ownerID: UUID? = nil,
        deletedAt: Date? = nil,
        syncedAt: Date? = nil
    ) {
        self.id = id
        self.text = text
        self.date = date
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.ownerID = ownerID
        self.deletedAt = deletedAt
        self.syncedAt = syncedAt
    }
}

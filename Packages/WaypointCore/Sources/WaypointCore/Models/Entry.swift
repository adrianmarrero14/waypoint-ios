import Foundation
import SwiftData

/// A single journal entry. Year/Month/Week grouping is derived from `date`
/// with `Calendar` — never modeled as separate entities.
///
/// CloudKit-compatible: every stored property has a default value, no unique
/// constraints, no required relationships. Future additions (photos, tags)
/// must be optional properties or optional relationships so the schema stays
/// lightweight-migratable.
@Model
public final class Entry {
    /// Free-form text of the entry.
    public var text: String = ""
    /// The day the entry refers to (user-editable, defaults to today).
    public var date: Date = Date.now
    /// When the entry was written.
    public var createdAt: Date = Date.now

    public init(text: String = "", date: Date = .now, createdAt: Date = .now) {
        self.text = text
        self.date = date
        self.createdAt = createdAt
    }
}

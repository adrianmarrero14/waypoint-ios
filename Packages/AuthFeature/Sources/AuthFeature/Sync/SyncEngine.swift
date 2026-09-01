import Foundation
import Observation
import PostgREST
import SwiftData
import WaypointCore

/// Offline-first sync between the local SwiftData store and the `waves` table.
/// Push-then-pull, last-write-wins by `updatedAt` (client-stamped clock).
/// Runs on the MainActor (package default): fine at journal scale; the scaling
/// path is a ModelActor opting out of default isolation.
@Observable
public final class SyncEngine {
    public private(set) var isSyncing = false
    public private(set) var lastError: Error?

    private let sessionStore: SessionStore
    private let waveStore: WaveStore
    private let config: SupabaseConfig
    private let modelContext: ModelContext
    private let defaults: UserDefaults = .standard

    @ObservationIgnored private var debounceTask: Task<Void, Never>?
    @ObservationIgnored private var pendingRerun = false

    public init(
        sessionStore: SessionStore,
        waveStore: WaveStore,
        config: SupabaseConfig,
        modelContext: ModelContext
    ) {
        self.sessionStore = sessionStore
        self.waveStore = waveStore
        self.config = config
        self.modelContext = modelContext
    }

    /// Debounced trigger for local mutations.
    public func scheduleSync() {
        debounceTask?.cancel()
        debounceTask = Task { [weak self] in
            try? await Task.sleep(for: .seconds(2))
            guard !Task.isCancelled else { return }
            await self?.syncNow()
        }
    }

    /// Adopts unowned local waves into the account, then does a full sync.
    public func handleSignIn(_ user: AuthUser) async {
        waveStore.adoptOrphans(ownerID: user.id)
        await syncNow()
    }

    /// Serialized push-then-pull; an overlapping call queues one rerun.
    public func syncNow() async {
        guard case .signedIn(let user) = sessionStore.state else { return }
        if isSyncing {
            pendingRerun = true
            return
        }
        isSyncing = true
        defer { isSyncing = false }

        repeat {
            pendingRerun = false
            do {
                let client = try await makeClient()
                try await push(userID: user.id, client: client)
                try await pull(userID: user.id, client: client)
                lastError = nil
            } catch {
                // Dirty rows stay dirty (syncedAt untouched); the next
                // trigger retries automatically.
                lastError = error
                return
            }
        } while pendingRerun
    }

    // MARK: - Push

    private func push(userID: UUID, client: PostgrestClient) async throws {
        let owned = try modelContext.fetch(
            FetchDescriptor<Wave>(predicate: #Predicate { $0.ownerID == userID })
        )
        // #Predicate can't compare two properties; filter dirtiness in memory.
        let dirty = owned.filter { wave in
            wave.syncedAt.map { wave.updatedAt > $0 } ?? true
        }
        guard !dirty.isEmpty else { return }

        // Capture updatedAt before the await: an edit landing mid-push bumps
        // updatedAt past the captured stamp and the row stays dirty.
        let captured = dirty.map { ($0, $0.updatedAt) }
        let records = dirty.map { WaveRecord(wave: $0, userID: userID) }

        try await client.from("waves")
            .upsert(records, onConflict: "id", returning: .minimal)
            .execute()
        for (wave, stamp) in captured {
            wave.syncedAt = stamp
        }
        try modelContext.save()
    }

    // MARK: - Pull

    private func pull(userID: UUID, client: PostgrestClient) async throws {
        let key = "waypoint.sync.lastPulledAt.\(userID.uuidString)"
        let stored = defaults.object(forKey: key) as? Date
        // 60s overlap absorbs clock skew between devices; apply is idempotent.
        let watermark = (stored ?? .distantPast).addingTimeInterval(-60)

        let records: [WaveRecord] = try await client.from("waves")
            .select()
            .gt("updated_at", value: Self.isoFormatter.string(from: watermark))
            .execute()
            .value
        guard !records.isEmpty else { return }

        var maxUpdated = stored ?? .distantPast
        for record in records {
            let recordID = record.id
            let existing = try modelContext.fetch(
                FetchDescriptor<Wave>(predicate: #Predicate { $0.id == recordID })
            ).first

            if let existing {
                if record.updatedAt > existing.updatedAt {
                    existing.text = record.text
                    existing.date = record.date
                    existing.createdAt = record.createdAt
                    existing.updatedAt = record.updatedAt
                    existing.ownerID = record.userID
                    existing.deletedAt = record.deletedAt
                    existing.syncedAt = record.updatedAt
                }
                // Local newer or equal: local wins (dirty rows push later).
            } else {
                modelContext.insert(Wave(
                    id: record.id,
                    text: record.text,
                    date: record.date,
                    createdAt: record.createdAt,
                    updatedAt: record.updatedAt,
                    ownerID: record.userID,
                    deletedAt: record.deletedAt,
                    syncedAt: record.updatedAt
                ))
            }
            maxUpdated = max(maxUpdated, record.updatedAt)
        }
        try modelContext.save()
        defaults.set(maxUpdated, forKey: key)
    }

    // MARK: - Client

    private func makeClient() async throws -> PostgrestClient {
        let session = try await sessionStore.client.session
        return PostgrestClient(
            url: config.url.appendingPathComponent("rest/v1"),
            headers: [
                "apikey": config.anonKey,
                "Authorization": "Bearer \(session.accessToken)",
            ],
            encoder: Self.encoder,
            decoder: Self.decoder
        )
    }

    // MARK: - Coding

    private struct WaveRecord: Codable {
        let id: UUID
        let userID: UUID
        let text: String
        let date: Date
        let createdAt: Date
        let updatedAt: Date
        let deletedAt: Date?

        enum CodingKeys: String, CodingKey {
            case id, text, date
            case userID = "user_id"
            case createdAt = "created_at"
            case updatedAt = "updated_at"
            case deletedAt = "deleted_at"
        }

        init(wave: Wave, userID: UUID) {
            self.id = wave.id
            self.userID = userID
            self.text = wave.text
            self.date = wave.date
            self.createdAt = wave.createdAt
            self.updatedAt = wave.updatedAt
            self.deletedAt = wave.deletedAt
        }
    }

    private static let isoFormatter: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter
    }()

    private static let isoFormatterNoFraction: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime]
        return formatter
    }()

    private static let encoder: JSONEncoder = {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .custom { date, encoder in
            var container = encoder.singleValueContainer()
            try container.encode(isoFormatter.string(from: date))
        }
        return encoder
    }()

    private static let decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .custom { decoder in
            let container = try decoder.singleValueContainer()
            let string = try container.decode(String.self)
            if let date = isoFormatter.date(from: string)
                ?? isoFormatterNoFraction.date(from: string) {
                return date
            }
            throw DecodingError.dataCorruptedError(
                in: container,
                debugDescription: "Unparseable date: \(string)"
            )
        }
        return decoder
    }()
}

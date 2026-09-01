import AuthFeature
import DesignSystem
import SwiftData
import SwiftUI
import WaypointCore

@main
struct waypointApp: App {
    @State private var moduleSettings = ModuleSettings()
    @State private var languageSettings = LanguageSettings()
    @State private var appearanceSettings = AppearanceSettings()
    @State private var appLockSettings = AppLockSettings()
    @State private var appLockManager = AppLockManager()
    @State private var sessionStore: SessionStore
    @State private var waveStore: WaveStore
    @State private var syncEngine: SyncEngine
    @State private var router: AppRouter
    @State private var notificationScheduler: NotificationScheduler

    @Environment(\.scenePhase) private var scenePhase

    private let container: ModelContainer
    private let notificationDelegate: NotificationDelegate

    init() {
        WaypointAppearance.apply()

        container = Self.makeContainer()
        let sessionStore = SessionStore(config: SupabaseEnvironment.config)
        let waveStore = WaveStore(modelContext: container.mainContext)
        let syncEngine = SyncEngine(
            sessionStore: sessionStore,
            waveStore: waveStore,
            config: SupabaseEnvironment.config,
            modelContext: container.mainContext
        )
        waveStore.onLocalChange = { syncEngine.scheduleSync() }
        _sessionStore = State(initialValue: sessionStore)
        _waveStore = State(initialValue: waveStore)
        _syncEngine = State(initialValue: syncEngine)

        let router = AppRouter()
        let scheduler = NotificationScheduler()
        _router = State(initialValue: router)
        _notificationScheduler = State(initialValue: scheduler)
        notificationDelegate = NotificationDelegate(router: router, scheduler: scheduler)

        #if DEBUG
        if ProcessInfo.processInfo.arguments.contains("-seedSampleData") {
            SampleData.seedIfEmpty(context: container.mainContext)
        }
        #endif
    }

    /// Pre-release schema policy: if the store on disk predates the current
    /// schema (e.g. the Entry→Wave rename), delete it and start fresh rather
    /// than crash. Replace with a versioned migration once real data exists.
    private static func makeContainer() -> ModelContainer {
        let schema = Schema([Wave.self])
        let config = ModelConfiguration(schema: schema, cloudKitDatabase: .none)
        do {
            return try ModelContainer(for: schema, configurations: [config])
        } catch {
            let storeURL = config.url
            let fm = FileManager.default
            for suffix in ["", "-shm", "-wal"] {
                try? fm.removeItem(at: URL(fileURLWithPath: storeURL.path + suffix))
            }
            return try! ModelContainer(for: schema, configurations: [config])
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(moduleSettings)
                .environment(languageSettings)
                .environment(appearanceSettings)
                .environment(router)
                .environment(notificationScheduler)
                .environment(appLockSettings)
                .environment(appLockManager)
                .environment(sessionStore)
                .environment(waveStore)
                .environment(syncEngine)
                .task {
                    appLockManager.lockIfEnabled(appLockSettings)
                }
        }
        .modelContainer(container)
        .onChange(of: sessionStore.state, initial: true) { oldState, newState in
            switch newState {
            case .signedIn(let user):
                waveStore.setCurrentUser(user.id)
                // Only a genuine account change triggers adoption + full sync;
                // token refreshes re-emit the same user and must not.
                if oldState.user?.id != user.id {
                    Task { await syncEngine.handleSignIn(user) }
                }
            case .signedOut:
                waveStore.setCurrentUser(nil)
            case .unknown:
                break
            }
        }
        .onChange(of: scenePhase) { _, phase in
            if phase == .background {
                appLockManager.lockIfEnabled(appLockSettings)
            }
            guard phase == .active else { return }
            Task {
                await syncEngine.syncNow()
                waveStore.purgeSyncedTombstones()
            }
            Task {
                await notificationScheduler.refreshAuthorizationStatus()
                guard notificationScheduler.isAuthorized else { return }
                notificationScheduler.scheduleWeeklyReminder()
                await notificationScheduler.rearmMonthlyIfNeeded()
            }
        }
    }
}

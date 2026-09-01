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
    @State private var sessionStore = SessionStore(config: SupabaseEnvironment.config)
    @State private var waveStore: WaveStore
    @State private var router: AppRouter
    @State private var notificationScheduler: NotificationScheduler

    @Environment(\.scenePhase) private var scenePhase

    private let container: ModelContainer
    private let notificationDelegate: NotificationDelegate

    init() {
        WaypointAppearance.apply()

        container = Self.makeContainer()
        _waveStore = State(initialValue: WaveStore(modelContext: container.mainContext))

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
                .task {
                    appLockManager.lockIfEnabled(appLockSettings)
                }
        }
        .modelContainer(container)
        .onChange(of: scenePhase) { _, phase in
            if phase == .background {
                appLockManager.lockIfEnabled(appLockSettings)
            }
            guard phase == .active else { return }
            Task {
                await notificationScheduler.refreshAuthorizationStatus()
                guard notificationScheduler.isAuthorized else { return }
                notificationScheduler.scheduleWeeklyReminder()
                await notificationScheduler.rearmMonthlyIfNeeded()
            }
        }
    }
}

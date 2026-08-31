import DesignSystem
import SwiftData
import SwiftUI
import WaypointCore

@main
struct waypointApp: App {
    @State private var moduleSettings = ModuleSettings()
    @State private var languageSettings = LanguageSettings()
    @State private var appearanceSettings = AppearanceSettings()
    @State private var router: AppRouter
    @State private var notificationScheduler: NotificationScheduler

    @Environment(\.scenePhase) private var scenePhase

    private let container: ModelContainer
    private let notificationDelegate: NotificationDelegate

    init() {
        WaypointAppearance.apply()

        let schema = Schema([Entry.self])
        let localConfig = ModelConfiguration(schema: schema, cloudKitDatabase: .none)
        container = try! ModelContainer(for: schema, configurations: [localConfig])

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

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(moduleSettings)
                .environment(languageSettings)
                .environment(appearanceSettings)
                .environment(router)
                .environment(notificationScheduler)
        }
        .modelContainer(container)
        .onChange(of: scenePhase) { _, phase in
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

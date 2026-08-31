import Foundation
import UserNotifications
import WaypointCore

/// Routes notification taps into the app and re-arms the monthly reminder.
final class NotificationDelegate: NSObject, UNUserNotificationCenterDelegate {
    private let router: AppRouter
    private let scheduler: NotificationScheduler

    @MainActor
    init(router: AppRouter, scheduler: NotificationScheduler) {
        self.router = router
        self.scheduler = scheduler
        super.init()
        UNUserNotificationCenter.current().delegate = self
    }

    nonisolated func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse
    ) async {
        let request = response.notification.request
        let route = request.content.userInfo["route"] as? String
        await MainActor.run {
            if route == NotificationScheduler.quickAddRoute {
                router.openWaypointQuickAdd()
            }
            if request.identifier == NotificationScheduler.monthlyIdentifier {
                scheduler.scheduleNextMonthlyReminder()
            }
        }
    }

    nonisolated func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification
    ) async -> UNNotificationPresentationOptions {
        if notification.request.identifier == NotificationScheduler.monthlyIdentifier {
            await MainActor.run { scheduler.scheduleNextMonthlyReminder() }
        }
        return [.banner, .sound]
    }
}

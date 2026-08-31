import Foundation
import UserNotifications

/// Schedules the journal reminder notifications.
///
/// - Weekly: every Sunday at 20:00, a repeating calendar trigger.
/// - Monthly: last day of the month at 20:00. Calendar triggers cannot repeat
///   on "last day of month", so a single non-repeating request is scheduled and
///   re-armed when it fires (delegate) and on every foreground (safety net).
@MainActor
@Observable
final class NotificationScheduler {
    static let weeklyIdentifier = "waypoint.weekly"
    static let monthlyIdentifier = "waypoint.monthly"
    static let quickAddRoute = "waypoint.quickAdd"

    private let center = UNUserNotificationCenter.current()

    /// Whether the user granted notification permission.
    private(set) var isAuthorized = false

    func refreshAuthorizationStatus() async {
        let settings = await center.notificationSettings()
        isAuthorized = settings.authorizationStatus == .authorized
    }

    /// Requests permission if not determined yet. Returns whether it is granted.
    @discardableResult
    func requestAuthorization() async -> Bool {
        let granted = (try? await center.requestAuthorization(options: [.alert, .sound, .badge])) ?? false
        isAuthorized = granted
        return granted
    }

    /// Schedules (or replaces) both reminders. Idempotent.
    func scheduleReminders() {
        scheduleWeeklyReminder()
        scheduleNextMonthlyReminder()
    }

    /// Repeating trigger: every Sunday at 20:00.
    func scheduleWeeklyReminder() {
        let content = UNMutableNotificationContent()
        content.title = String(localized: "notification.weekly.title")
        content.body = String(localized: "notification.weekly.body")
        content.sound = .default
        content.userInfo = ["route": Self.quickAddRoute]

        var components = DateComponents()
        components.weekday = 1 // Sunday
        components.hour = 20
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        let request = UNNotificationRequest(
            identifier: Self.weeklyIdentifier, content: content, trigger: trigger
        )
        center.add(request)
    }

    /// Non-repeating trigger on the next last-day-of-month at 20:00 after `date`.
    func scheduleNextMonthlyReminder(after date: Date = .now) {
        guard let fireDate = Self.nextEndOfMonth(after: date) else { return }
        let calendar = Calendar.current

        let content = UNMutableNotificationContent()
        content.title = String(localized: "notification.monthly.title")
        let monthName = fireDate.formatted(.dateTime.month(.wide))
        content.body = String(localized: "notification.monthly.body \(monthName)")
        content.sound = .default
        content.userInfo = ["route": Self.quickAddRoute]

        let components = calendar.dateComponents([.year, .month, .day, .hour], from: fireDate)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        let request = UNNotificationRequest(
            identifier: Self.monthlyIdentifier, content: content, trigger: trigger
        )
        center.add(request)
    }

    /// Re-schedules the monthly reminder if none is pending (e.g. it fired and
    /// was dismissed without interaction, so the delegate never re-armed it).
    func rearmMonthlyIfNeeded() async {
        let pending = await center.pendingNotificationRequests()
        guard !pending.contains(where: { $0.identifier == Self.monthlyIdentifier }) else { return }
        scheduleNextMonthlyReminder()
    }

    /// The next "last day of a month at 20:00" strictly after `date`.
    static func nextEndOfMonth(after date: Date, calendar: Calendar = .current) -> Date? {
        var candidateMonth = date
        // Check this month first; if its last-day-20:00 already passed, use next month's.
        for _ in 0..<2 {
            guard let interval = calendar.dateInterval(of: .month, for: candidateMonth),
                  let lastDay = calendar.date(byAdding: .day, value: -1, to: interval.end),
                  let fireDate = calendar.date(
                    bySettingHour: 20, minute: 0, second: 0, of: lastDay
                  )
            else { return nil }
            if fireDate > date { return fireDate }
            candidateMonth = interval.end
        }
        return nil
    }
}

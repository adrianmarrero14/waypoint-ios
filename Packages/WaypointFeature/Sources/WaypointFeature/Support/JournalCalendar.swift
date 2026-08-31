import Foundation

/// ISO 8601 (Monday–Sunday) calendar math for grouping entries by week.
enum JournalCalendar {
    nonisolated(unsafe) static let iso: Calendar = {
        var calendar = Calendar(identifier: .iso8601)
        calendar.timeZone = .autoupdatingCurrent
        return calendar
    }()
}

/// Identifies an ISO week (e.g. 2026-W35). Uses `yearForWeekOfYear`, so weeks
/// spanning a year boundary are keyed consistently.
struct WeekKey: Hashable, Comparable {
    let yearForWeek: Int
    let week: Int

    init(date: Date) {
        let calendar = JournalCalendar.iso
        yearForWeek = calendar.component(.yearForWeekOfYear, from: date)
        week = calendar.component(.weekOfYear, from: date)
    }

    static func < (lhs: WeekKey, rhs: WeekKey) -> Bool {
        (lhs.yearForWeek, lhs.week) < (rhs.yearForWeek, rhs.week)
    }

    /// The full Monday–Sunday interval of this week.
    var interval: DateInterval? {
        let calendar = JournalCalendar.iso
        var components = DateComponents()
        components.yearForWeekOfYear = yearForWeek
        components.weekOfYear = week
        guard let start = calendar.date(from: components) else { return nil }
        return calendar.dateInterval(of: .weekOfYear, for: start)
    }
}

extension JournalCalendar {
    /// The month interval for a given year/month.
    static func monthInterval(year: Int, month: Int) -> DateInterval? {
        guard let start = iso.date(from: DateComponents(year: year, month: month)) else {
            return nil
        }
        return iso.dateInterval(of: .month, for: start)
    }

    /// The ISO weeks overlapping a month, in order — one per heatmap cell.
    static func weeks(inMonthOf year: Int, month: Int) -> [WeekKey] {
        guard let interval = monthInterval(year: year, month: month) else { return [] }
        var keys: [WeekKey] = []
        var cursor = interval.start
        while cursor < interval.end {
            keys.append(WeekKey(date: cursor))
            guard let weekEnd = iso.dateInterval(of: .weekOfYear, for: cursor)?.end else { break }
            cursor = weekEnd
        }
        return keys
    }
}

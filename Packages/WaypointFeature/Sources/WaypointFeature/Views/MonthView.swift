import DesignSystem
import SwiftData
import SwiftUI
import WaypointCore

/// Entries of one month, grouped into a section per ISO week.
struct MonthView: View {
    let year: Int
    let month: Int

    @Environment(\.modelContext) private var modelContext
    @Query private var entries: [Entry]
    @State private var isQuickAddPresented = false
    @State private var entryToEdit: Entry?

    init(year: Int, month: Int) {
        self.year = year
        self.month = month
        let interval = JournalCalendar.monthInterval(year: year, month: month)
        // #Predicate cannot call Calendar — capture plain Date bounds.
        let start = interval?.start ?? .distantPast
        let end = interval?.end ?? .distantFuture
        _entries = Query(
            filter: #Predicate<Entry> { $0.date >= start && $0.date < end },
            sort: \Entry.date
        )
    }

    private var monthStart: Date {
        JournalCalendar.monthInterval(year: year, month: month)?.start ?? .now
    }

    private var weekGroups: [(key: WeekKey, entries: [Entry])] {
        Dictionary(grouping: entries) { WeekKey(date: $0.date) }
            .sorted { $0.key < $1.key }
            .map { (key: $0.key, entries: $0.value) }
    }

    var body: some View {
        Group {
            if entries.isEmpty {
                WaypointEmptyState(
                    title: Text("month.empty.title", bundle: .module),
                    message: Text("month.empty.message", bundle: .module),
                    systemImage: "water.waves"
                )
            } else {
                List {
                    ForEach(weekGroups, id: \.key) { group in
                        Section {
                            ForEach(group.entries) { entry in
                                Button {
                                    entryToEdit = entry
                                } label: {
                                    EntryRow(entry: entry)
                                }
                                .buttonStyle(.plain)
                            }
                            .onDelete { offsets in
                                for offset in offsets {
                                    modelContext.delete(group.entries[offset])
                                }
                            }
                        } header: {
                            WeekHeader(key: group.key)
                        }
                        .listRowBackground(Color.wpSurface)
                    }
                }
                .scrollContentBackground(.hidden)
            }
        }
        .background(Color.wpBackground)
        .navigationTitle(monthStart.formatted(.dateTime.month(.wide).year()))
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                AddEntryButton { isQuickAddPresented = true }
            }
        }
        .sheet(isPresented: $isQuickAddPresented) {
            QuickAddView(initialDate: defaultQuickAddDate)
        }
        .sheet(item: $entryToEdit) { entry in
            QuickAddView(entry: entry)
        }
    }

    /// Today when browsing the current month; otherwise the month's first day.
    private var defaultQuickAddDate: Date {
        let now = Date.now
        let calendar = JournalCalendar.iso
        if calendar.component(.year, from: now) == year,
           calendar.component(.month, from: now) == month {
            return now
        }
        return monthStart
    }
}

private struct WeekHeader: View {
    let key: WeekKey

    var body: some View {
        HStack(spacing: 8) {
            Text("week.header \(key.week)", bundle: .module)
            if let interval = key.interval {
                Text(rangeText(for: interval))
                    .textCase(nil)
                    .font(.nunito(13, weight: .semiBold))
                    .foregroundStyle(Color.wpTextTertiary)
            }
        }
        .waypointLabelStyle()
    }

    private func rangeText(for interval: DateInterval) -> String {
        // dateInterval(of: .weekOfYear).end is the next Monday; show Mon–Sun.
        let lastDay = interval.end.addingTimeInterval(-1)
        return (interval.start..<lastDay).formatted(.interval.day().month(.abbreviated))
    }
}

private struct EntryRow: View {
    let entry: Entry

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(entry.text)
                .font(.wpBody)
                .foregroundStyle(Color.wpTextPrimary)
            Text(entry.date.formatted(.dateTime.weekday(.wide).day()))
                .font(.wpCaption)
                .foregroundStyle(Color.wpTextTertiary)
        }
        .padding(.vertical, 2)
    }
}

#Preview {
    NavigationStack {
        MonthView(
            year: JournalCalendar.iso.component(.year, from: .now),
            month: JournalCalendar.iso.component(.month, from: .now)
        )
    }
    .modelContainer(PreviewData.makeContainer())
}

import DesignSystem
import SwiftData
import SwiftUI
import WaypointCore

/// Waves of one month, grouped into a section per ISO week.
struct MonthView: View {
    let year: Int
    let month: Int

    @Environment(WaveStore.self) private var waveStore
    @Query private var waves: [Wave]
    @State private var isQuickAddPresented = false
    @State private var waveToEdit: Wave?

    init(year: Int, month: Int, ownerID: UUID?) {
        self.year = year
        self.month = month
        let interval = JournalCalendar.monthInterval(year: year, month: month)
        // #Predicate cannot call Calendar — capture plain Date bounds.
        let start = interval?.start ?? .distantPast
        let end = interval?.end ?? .distantFuture
        _waves = Query(
            filter: #Predicate<Wave> {
                $0.date >= start && $0.date < end
                    && $0.deletedAt == nil
                    && ($0.ownerID == nil || $0.ownerID == ownerID)
            },
            sort: \Wave.date
        )
    }

    private var monthStart: Date {
        JournalCalendar.monthInterval(year: year, month: month)?.start ?? .now
    }

    private var weekGroups: [(key: WeekKey, waves: [Wave])] {
        Dictionary(grouping: waves) { WeekKey(date: $0.date) }
            .sorted { $0.key < $1.key }
            .map { (key: $0.key, waves: $0.value) }
    }

    var body: some View {
        Group {
            if waves.isEmpty {
                WaypointEmptyState(
                    title: Text("month.empty.title", bundle: .module),
                    message: Text("month.empty.message", bundle: .module),
                    systemImage: "water.waves"
                )
            } else {
                List {
                    ForEach(weekGroups, id: \.key) { group in
                        Section {
                            ForEach(group.waves) { wave in
                                Button {
                                    waveToEdit = wave
                                } label: {
                                    WaveRow(wave: wave)
                                }
                                .buttonStyle(.plain)
                            }
                            .onDelete { offsets in
                                for offset in offsets {
                                    waveStore.delete(group.waves[offset])
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
                AddWaveButton { isQuickAddPresented = true }
            }
        }
        .sheet(isPresented: $isQuickAddPresented) {
            QuickAddView(initialDate: defaultQuickAddDate)
        }
        .sheet(item: $waveToEdit) { wave in
            QuickAddView(wave: wave)
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

private struct WaveRow: View {
    let wave: Wave

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(wave.text)
                .font(.wpBody)
                .foregroundStyle(Color.wpTextPrimary)
            Text(wave.date.formatted(.dateTime.weekday(.wide).day()))
                .font(.wpCaption)
                .foregroundStyle(Color.wpTextTertiary)
        }
        .padding(.vertical, 2)
    }
}

#Preview {
    let container = PreviewData.makeContainer()
    NavigationStack {
        MonthView(
            year: JournalCalendar.iso.component(.year, from: .now),
            month: JournalCalendar.iso.component(.month, from: .now),
            ownerID: nil
        )
    }
    .modelContainer(container)
    .environment(PreviewData.makeStore(container: container))
}

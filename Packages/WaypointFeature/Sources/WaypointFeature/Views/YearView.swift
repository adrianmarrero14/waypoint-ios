import DesignSystem
import SwiftData
import SwiftUI
import WaypointCore

/// A month grid destination within the year.
struct MonthDestination: Hashable {
    let year: Int
    let month: Int
}

/// Full-width month cards for the selected year, chronological top to bottom,
/// each previewing the entries written that month. The header (title + year)
/// stays pinned and the list opens focused on the current month.
struct YearView: View {
    @Query(sort: \Entry.date) private var entries: [Entry]
    @State private var selectedYear = JournalCalendar.iso.component(.year, from: .now)

    private var currentYear: Int {
        JournalCalendar.iso.component(.year, from: .now)
    }

    private var currentMonth: Int {
        JournalCalendar.iso.component(.month, from: .now)
    }

    /// Months shown for the selected year, chronological top to bottom. The
    /// current year ends at the current month, plus the next three months
    /// peeking below so the current one reads as the focus of the list.
    private var months: [Int] {
        let latest = selectedYear == currentYear
            ? min(currentMonth + 3, 12)
            : 12
        return Array(1...latest)
    }

    /// Whether a month of the selected year is still in the future.
    private func isUpcoming(_ month: Int) -> Bool {
        selectedYear == currentYear && month > currentMonth
    }

    private var yearEntries: [Entry] {
        entries.filter { JournalCalendar.iso.component(.year, from: $0.date) == selectedYear }
    }

    /// Entries per month (1...12), chronological (the query sorts by date).
    private var entriesByMonth: [Int: [Entry]] {
        Dictionary(grouping: yearEntries) {
            JournalCalendar.iso.component(.month, from: $0.date)
        }
    }

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(spacing: 16) {
                    ForEach(months, id: \.self) { month in
                        NavigationLink(value: MonthDestination(year: selectedYear, month: month)) {
                            let monthEntries = entriesByMonth[month] ?? []
                            MonthCard(
                                year: selectedYear,
                                month: month,
                                entryCount: monthEntries.count,
                                previewEntries: monthEntries,
                                isUpcoming: isUpcoming(month)
                            )
                        }
                        .buttonStyle(.plain)
                        .disabled(isUpcoming(month))
                        .id(month)
                    }
                }
                .padding(20)
            }
            .onAppear {
                if selectedYear == currentYear {
                    proxy.scrollTo(currentMonth, anchor: .center)
                }
            }
        }
        .safeAreaInset(edge: .top, spacing: 0) {
            yearSwitcher
                .padding(.horizontal, 20)
                .padding(.vertical, 8)
                .background(Color.wpBackground)
        }
        .background(Color.wpBackground)
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(for: MonthDestination.self) { destination in
            MonthView(year: destination.year, month: destination.month)
        }
    }

    private var yearSwitcher: some View {
        HStack {
            Button {
                selectedYear -= 1
            } label: {
                Image(systemName: "chevron.left.circle.fill")
                    .font(.system(size: 26))
            }
            .tint(Color.wpLabelAccent)

            Spacer()
            Text(String(selectedYear))
                .font(.wpTitle)
                .foregroundStyle(Color.wpTextPrimary)
                .monospacedDigit()
            Spacer()

            Button {
                selectedYear += 1
            } label: {
                Image(systemName: "chevron.right.circle.fill")
                    .font(.system(size: 26))
            }
            .tint(Color.wpLabelAccent)
            .disabled(selectedYear >= currentYear)
            .opacity(selectedYear >= currentYear ? 0.3 : 1)
        }
        .padding(.horizontal, 4)
    }
}

#Preview {
    NavigationStack {
        YearView()
            .navigationTitle(Text("module.waypoint.name", bundle: .module))
    }
    .modelContainer(PreviewData.makeContainer())
}

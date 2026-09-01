import DesignSystem
import SwiftUI
import WaypointCore

/// One month in the year list: name, wave count and a preview of the first
/// waves written that month.
struct MonthCard: View {
    let year: Int
    let month: Int
    let waveCount: Int
    let previewWaves: [Wave]
    /// Future month peeking at the bottom of the list: bold name, dimmed card.
    var isUpcoming = false

    private var monthName: String {
        let date = JournalCalendar.monthInterval(year: year, month: month)?.start ?? .now
        return date.formatted(.dateTime.month(.wide)).capitalized
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .firstTextBaseline) {
                Text(monthName)
                    .font(.fredoka(20, weight: isUpcoming ? .bold : .semiBold))
                    .foregroundStyle(Color.wpTextPrimary)
                Spacer()
                if !isUpcoming {
                    Text("month.waves.count \(waveCount)", bundle: .module)
                        .font(.wpCaption)
                        .foregroundStyle(waveCount > 0 ? Color.wpLabelAccent : Color.wpTextTertiary)
                }
            }
            if !previewWaves.isEmpty {
                VStack(alignment: .leading, spacing: 6) {
                    ForEach(previewWaves) { wave in
                        HStack(spacing: 8) {
                            Bubble(diameter: 8)
                            Text(wave.text)
                                .font(.wpCaption)
                                .foregroundStyle(Color.wpTextSecondary)
                                .lineLimit(1)
                        }
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .waypointCard(padding: 16)
        .opacity(isUpcoming ? 0.45 : 1)
    }
}

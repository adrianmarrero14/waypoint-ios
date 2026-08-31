import Foundation
import SwiftData

/// Debug/test seeding for the journal. Lives next to the model so both the app
/// target (simulator seeding) and feature previews can use it.
public enum SampleData {
    /// Inserts sample entries spread across the current year if the store is empty.
    public static func seedIfEmpty(context: ModelContext) {
        let count = (try? context.fetchCount(FetchDescriptor<Entry>())) ?? 0
        guard count == 0 else { return }
        seed(context: context)
    }

    /// Inserts sample entries spread over the last ~10 months, several per month
    /// with uneven weekly distribution so the heatmap has visible variation.
    public static func seed(context: ModelContext) {
        let calendar = Calendar(identifier: .iso8601)
        let now = Date.now
        let texts = [
            "Fui al cine con mi novia",
            "Cena con la familia en casa",
            "Empecé un libro nuevo",
            "Paseo largo por la playa",
            "Quedada con amigos del insti",
            "Primer día en el proyecto nuevo",
            "Escapada de fin de semana",
            "Concierto en la ciudad",
            "Día de lluvia y series",
            "Comida de cumpleaños",
            "Ruta de senderismo",
            "Tarde de juegos de mesa",
        ]
        // Deterministic-ish spread: for each of the last 10 months, drop entries
        // on a handful of specific days so weeks fill unevenly.
        let dayOffsets = [1, 2, 3, 9, 10, 17, 25, 26, 27, 28]
        for monthBack in 0..<10 {
            guard let monthDate = calendar.date(byAdding: .month, value: -monthBack, to: now),
                  let monthStart = calendar.dateInterval(of: .month, for: monthDate)?.start
            else { continue }
            let perMonth = 2 + (monthBack * 3) % 7
            for i in 0..<perMonth {
                let day = dayOffsets[i % dayOffsets.count]
                guard let date = calendar.date(byAdding: .day, value: day - 1, to: monthStart),
                      date <= now
                else { continue }
                let text = texts[(monthBack + i * 5) % texts.count]
                context.insert(Entry(text: text, date: date, createdAt: date))
            }
        }
        try? context.save()
    }
}

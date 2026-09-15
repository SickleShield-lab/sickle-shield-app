import WidgetKit
import SwiftUI

struct PainWidgetEntry: TimelineEntry {
    let date: Date
    let painScore: Double
    let water: String
}

struct PainWidgetProvider: TimelineProvider {
    func placeholder(in context: Context) -> PainWidgetEntry {
        PainWidgetEntry(date: Date(), painScore: 0, water: "-/-")
    }

    func getSnapshot(in context: Context, completion: @escaping (PainWidgetEntry) -> Void) {
        completion(makeEntry())
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<PainWidgetEntry>) -> Void) {
        let entry = makeEntry()
        // The app itself calls WidgetCenter.reloadAllTimelines() whenever it
        // fetches fresh data, so this refresh is just a safety net.
        let nextRefresh = Calendar.current.date(byAdding: .hour, value: 1, to: Date()) ?? Date()
        completion(Timeline(entries: [entry], policy: .after(nextRefresh)))
    }

    private func makeEntry() -> PainWidgetEntry {
        let snapshot = SharedStore.readWidgetSnapshot()
        return PainWidgetEntry(date: Date(), painScore: snapshot.painScore, water: snapshot.water)
    }
}

struct PainWidgetView: View {
    var entry: PainWidgetEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Sickle Shield")
                .font(.system(size: 10, weight: .medium))
                .foregroundStyle(.secondary)
            Spacer()
            HStack(alignment: .firstTextBaseline, spacing: 4) {
                Text(String(format: "%.1f", entry.painScore))
                    .font(.system(size: 22, weight: .semibold))
                Text("pain")
                    .font(.system(size: 11))
                    .foregroundStyle(.secondary)
            }
            Text("Water \(entry.water)")
                .font(.system(size: 11))
                .foregroundStyle(.secondary)
        }
        .padding()
        .containerBackground(for: .widget) { Color(red: 0.91, green: 0.91, blue: 0.92) }
    }
}

struct PainWidget: Widget {
    let kind = "PainWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: PainWidgetProvider()) { entry in
            PainWidgetView(entry: entry)
        }
        .configurationDisplayName("Pain & water")
        .description("Your latest pain score and water intake at a glance.")
        .supportedFamilies([.systemSmall])
    }
}

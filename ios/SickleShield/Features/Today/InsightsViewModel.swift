import Foundation

struct InsightPattern: Identifiable {
    let id = UUID()
    let text: String
    let kind: SSInsightKind
}

@MainActor
@Observable
final class InsightsViewModel {
    var records: [PainEntry] = []
    var insight: PainTrendInsight?
    var isLoading = false
    var errorMessage: String?

    /// "Your Recent Baseline" - nil sleep/medication values mean there's
    /// not enough data yet, rather than showing a fabricated number.
    var typicalPainRangeLabel = "—"
    var typicalSleepLabel: String?
    var medicationAdherenceLabel: String?
    var episodesThisMonth = 0

    var patterns: [InsightPattern] = []

    var average: Double { records.isEmpty ? 0 : Double(records.map(\.rating).reduce(0, +)) / Double(records.count) }
    var highest: Int { records.map(\.rating).max() ?? 0 }
    var lowest: Int { records.map(\.rating).min() ?? 0 }

    private let healthKitManager = HealthKitManager()

    func load() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        async let historyTask: PainHistoryResponse? = try? PainAPI.history(days: 30)
        async let sleepTask = healthKitManager.sleepHistory(days: 30)
        let history = await historyTask
        let sleepSamples = await sleepTask

        if let history {
            records = history.painRecords.sorted { $0.createdAt < $1.createdAt }
        } else {
            errorMessage = "Couldn't load your pain history."
        }

        episodesThisMonth = records.count
        typicalPainRangeLabel = Self.typicalRangeLabel(for: records.map(\.rating))
        medicationAdherenceLabel = Self.medicationAdherenceLabel(for: records)
        typicalSleepLabel = Self.typicalSleepLabel(for: sleepSamples)
        patterns = Self.computePatterns(records: records, average: average, sleepSamples: sleepSamples)

        let stats = PainTrendStats(
            average: average,
            highest: highest,
            lowest: lowest,
            episodeCount: records.count,
            hadCrisisAboveSix: records.contains { $0.rating > 6 }
        )
        insight = await PainInsightGenerator.generate(from: stats)
    }

    // MARK: - Baseline

    private static func typicalRangeLabel(for ratings: [Int]) -> String {
        guard !ratings.isEmpty else { return "—" }
        let sorted = ratings.sorted()
        let low = percentile(0.25, of: sorted)
        let high = percentile(0.75, of: sorted)
        return low == high ? "\(low)/10" : "\(low)-\(high)/10"
    }

    private static func percentile(_ p: Double, of sortedValues: [Int]) -> Int {
        guard !sortedValues.isEmpty else { return 0 }
        let index = Int((p * Double(sortedValues.count - 1)).rounded())
        return sortedValues[index]
    }

    private static func medicationAdherenceLabel(for records: [PainEntry]) -> String? {
        guard !records.isEmpty else { return nil }
        let withMedication = records.filter { $0.medicationTaken != nil }.count
        let percent = Int((Double(withMedication) / Double(records.count) * 100).rounded())
        return "\(percent)%"
    }

    private static func typicalSleepLabel(for samples: [SleepSample]) -> String? {
        guard !samples.isEmpty else { return nil }
        let average = samples.map(\.hours).reduce(0, +) / Double(samples.count)
        let totalMinutes = Int((average * 60).rounded())
        return "\(totalMinutes / 60)h \(totalMinutes % 60)m"
    }

    // MARK: - Patterns & Data

    private static func computePatterns(records: [PainEntry], average: Double, sleepSamples: [SleepSample]) -> [InsightPattern] {
        var patterns: [InsightPattern] = []
        let calendar = Calendar.current

        // Weekly trend vs recent average.
        if let weekAgo = calendar.date(byAdding: .day, value: -7, to: Date()) {
            let thisWeek = records.filter { $0.createdAt >= weekAgo }
            if !thisWeek.isEmpty {
                let thisWeekAverage = Double(thisWeek.map(\.rating).reduce(0, +)) / Double(thisWeek.count)
                if thisWeekAverage < average - 0.3 {
                    patterns.append(InsightPattern(text: "Your pain has been lower this week than your recent average.", kind: .pattern))
                } else if thisWeekAverage > average + 0.3 {
                    patterns.append(InsightPattern(text: "Your pain has been higher this week than your recent average.", kind: .pattern))
                }
            }
        }

        // Most common location.
        let locationCounts = Dictionary(grouping: records.filter { !$0.pain.isEmpty }, by: { $0.pain }).mapValues(\.count)
        if let top = locationCounts.max(by: { $0.value < $1.value }), top.value >= 2 {
            patterns.append(InsightPattern(text: "Most of your crises this month were reported in your \(top.key).", kind: .data))
        }

        // Sleep correlation - only claim this if there's enough overlapping
        // data between pain days and sleep days to actually support it.
        if sleepSamples.count >= 3 {
            let overallAverageSleep = sleepSamples.map(\.hours).reduce(0, +) / Double(sleepSamples.count)
            let sleepByDay = Dictionary(uniqueKeysWithValues: sleepSamples.map { ($0.day, $0.hours) })
            let paintDaysBelowTypicalSleep: [Bool] = records.compactMap { entry in
                let day = calendar.startOfDay(for: entry.createdAt)
                guard let sleepHours = sleepByDay[day] else { return nil }
                return sleepHours < overallAverageSleep
            }
            if paintDaysBelowTypicalSleep.count >= 3 {
                let belowCount = paintDaysBelowTypicalSleep.filter { $0 }.count
                if Double(belowCount) / Double(paintDaysBelowTypicalSleep.count) >= 0.6 {
                    patterns.append(InsightPattern(text: "Pain was more often recorded on days you slept less than usual.", kind: .pattern))
                }
            }
        }

        return patterns
    }
}

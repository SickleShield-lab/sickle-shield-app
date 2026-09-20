import Foundation

enum PainRange: String, CaseIterable, Identifiable {
    case sevenDays = "7D"
    case thirtyDays = "30D"
    case threeMonths = "3M"
    case sixMonths = "6M"
    case oneYear = "1Y"

    var id: String { rawValue }

    var days: Int {
        switch self {
        case .sevenDays: return 7
        case .thirtyDays: return 30
        case .threeMonths: return 90
        case .sixMonths: return 180
        case .oneYear: return 365
        }
    }

    var rangeDescription: String {
        switch self {
        case .sevenDays: return "the last 7 days"
        case .thirtyDays: return "the last 30 days"
        case .threeMonths: return "the last 3 months"
        case .sixMonths: return "the last 6 months"
        case .oneYear: return "the last year"
        }
    }
}

@MainActor
@Observable
final class PainViewModel {
    /// Ascending by date - natural order for a trend chart.
    var records: [PainEntry] = []
    var isLoading = false
    var errorMessage: String?
    private var currentRange: PainRange = .thirtyDays

    var average: Double { records.isEmpty ? 0 : Double(records.map(\.rating).reduce(0, +)) / Double(records.count) }
    var highest: Int { records.map(\.rating).max() ?? 0 }
    var lowest: Int { records.map(\.rating).min() ?? 0 }

    var summaryText: String {
        guard let latest = records.last else {
            return "No pain entries logged in \(currentRange.rangeDescription) yet."
        }
        let direction: String
        if records.count >= 4 {
            let mid = records.count / 2
            let firstHalfAverage = Self.average(of: Array(records[..<mid]))
            let secondHalfAverage = Self.average(of: Array(records[mid...]))
            if secondHalfAverage < firstHalfAverage - 0.3 {
                direction = "trended down"
            } else if secondHalfAverage > firstHalfAverage + 0.3 {
                direction = "trended up"
            } else {
                direction = "stayed steady"
            }
        } else {
            direction = "was recorded"
        }
        let episodeWord = records.count == 1 ? "episode" : "episodes"
        return "Pain \(direction) over \(currentRange.rangeDescription), averaging \(String(format: "%.1f", average))/10 with \(records.count) \(episodeWord) recorded. Most recent entry: \(latest.rating)/10."
    }

    func load(range: PainRange) async {
        currentRange = range
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        do {
            let history = try await PainAPI.history(days: range.days)
            records = history.painRecords.sorted { $0.createdAt < $1.createdAt }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private static func average(of entries: [PainEntry]) -> Double {
        entries.isEmpty ? 0 : Double(entries.map(\.rating).reduce(0, +)) / Double(entries.count)
    }
}

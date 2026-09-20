import Foundation

struct PainEntry: Codable, Identifiable {
    let id: String
    let userId: String
    let pain: String
    let sensation: String
    let frequency: String
    let rating: Int
    let createdAt: Date
    let updatedAt: Date

    /// `sensation` has no dedicated UI of its own (every write site sends a
    /// fixed literal) - reused as a lightweight way to link a crisis log to
    /// the medication taken for it, encoded as "... | Medication: Name".
    /// See `TrackerViewModel.logCrisis`.
    var medicationTaken: String? {
        guard let range = sensation.range(of: "Medication: ") else { return nil }
        let value = sensation[range.upperBound...]
        return value.isEmpty ? nil : String(value)
    }
}

struct PainHistoryResponse: Codable {
    let painRecords: [PainEntry]
    let averageRating: Double
}

struct CreatePainRequest: Encodable {
    let pain: String
    let sensation: String
    let frequency: String
    let rating: Int
}

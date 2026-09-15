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

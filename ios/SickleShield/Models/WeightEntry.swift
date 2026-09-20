import Foundation

struct WeightEntry: Codable, Identifiable {
    let id: String
    let userId: String
    let weight: Double
    let loggedAt: Date
    let createdAt: Date
    let updatedAt: Date
}

struct LogWeightRequest: Encodable {
    let weight: Double
}

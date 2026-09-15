import Foundation

struct WaterIntakeStatus: Codable {
    let amount: Int
    let percentage: Double
    let target: Int
}

struct CreateWaterIntakeRequest: Encodable {
    let amount: Int
}

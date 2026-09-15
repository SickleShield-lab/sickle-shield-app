import Foundation

enum GoalAPI {
    static func waterIntake() async throws -> WaterIntakeStatus {
        try await APIClient.shared.request("goal/water-intake/goal", method: "GET")
    }

    static func logWaterIntake(amount: Int) async throws {
        let body = CreateWaterIntakeRequest(amount: amount)
        try await APIClient.shared.requestVoid("goal/water-intake", method: "POST", body: body)
    }
}

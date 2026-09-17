import Foundation

enum GoalAPI {
    static func waterIntake() async throws -> WaterIntakeStatus {
        try await APIClient.shared.request("goal/water-intake/goal", method: "GET")
    }

    static func logWaterIntake(amount: Int) async throws {
        let body = CreateWaterIntakeRequest(amount: amount)
        try await APIClient.shared.requestVoid("goal/water-intake", method: "POST", body: body)
    }

    static func currentWeightGoal(targetType: String = "week") async throws -> WeightGoalStatus {
        try await APIClient.shared.request("goal/weight/goals", method: "GET", query: ["targetType": targetType])
    }

    static func createWeightGoal(targetType: String, startWeight: Int, targetWeight: Int) async throws -> WeightGoal {
        let body = WeightGoalRequest(targetType: targetType, startWeight: startWeight, targetWeight: targetWeight)
        return try await APIClient.shared.request("goal/weight/create", method: "POST", body: body)
    }

    static func updateWeightGoal(id: String, targetType: String, startWeight: Int, targetWeight: Int) async throws -> WeightGoal {
        let body = WeightGoalRequest(targetType: targetType, startWeight: startWeight, targetWeight: targetWeight)
        return try await APIClient.shared.request("goal/weight/\(id)", method: "PATCH", body: body)
    }

    static func deleteWeightGoal(id: String) async throws {
        try await APIClient.shared.requestVoid("goal/weight/\(id)", method: "DELETE")
    }
}

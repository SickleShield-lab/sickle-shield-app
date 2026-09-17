import Foundation

struct WeightGoal: Codable, Identifiable {
    let id: String
    let userId: String
    let targetType: String
    let startWeight: Int
    let targetWeight: Int
    let createdAt: Date
    let updatedAt: Date
}

struct WeightGoalRequest: Encodable {
    let targetType: String
    let startWeight: Int
    let targetWeight: Int
}

/// Shape of `GET goal/weight/goals`, which differs from the create/update
/// response: `id` is null and startWeight/targetWeight are 0 when the user
/// hasn't set a goal for this targetType yet, rather than the endpoint
/// returning no goal at all.
struct WeightGoalStatus: Codable {
    let id: String?
    let targetType: String
    let startWeight: Int
    let targetWeight: Int
    let currentWeight: Double?
}

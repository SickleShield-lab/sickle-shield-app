import Foundation

@Observable
@MainActor
final class WeightViewModel {
    var status: WeightGoalStatus?
    var isLoading = false
    var isSaving = false
    var errorMessage: String?

    /// The GET endpoint always returns a shaped object (id is nil when no goal exists yet).
    var hasGoal: Bool { status?.id != nil }

    func load() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        do {
            status = try await GoalAPI.currentWeightGoal()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    @discardableResult
    func save(targetType: String, startWeight: Int, targetWeight: Int) async -> Bool {
        isSaving = true
        errorMessage = nil
        defer { isSaving = false }
        do {
            let saved: WeightGoal
            if let id = status?.id {
                saved = try await GoalAPI.updateWeightGoal(id: id, targetType: targetType, startWeight: startWeight, targetWeight: targetWeight)
            } else {
                saved = try await GoalAPI.createWeightGoal(targetType: targetType, startWeight: startWeight, targetWeight: targetWeight)
            }
            status = WeightGoalStatus(
                id: saved.id,
                targetType: saved.targetType,
                startWeight: saved.startWeight,
                targetWeight: saved.targetWeight,
                currentWeight: status?.currentWeight
            )
            return true
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }
}

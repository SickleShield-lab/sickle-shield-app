import Foundation

@Observable
@MainActor
final class WaterIntakeViewModel {
    var status: WaterIntakeStatus?
    var isLoading = false
    var isLogging = false
    var errorMessage: String?

    func load() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        do {
            status = try await GoalAPI.waterIntake()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func logGlass(_ amount: Int) async {
        isLogging = true
        errorMessage = nil
        defer { isLogging = false }
        do {
            try await GoalAPI.logWaterIntake(amount: amount)
            status = try await GoalAPI.waterIntake()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}

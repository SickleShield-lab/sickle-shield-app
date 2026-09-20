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

    func logGlasses(_ amount: Int) async {
        guard amount > 0 else { return }
        isLogging = true
        errorMessage = nil
        defer { isLogging = false }
        let previousAmount = status?.amount ?? 0
        do {
            try await GoalAPI.logWaterIntake(amount: amount)
            status = try await GoalAPI.waterIntake()
            await notifyIfGoalJustReached(previousAmount: previousAmount)
            if let status {
                LocalNotificationScheduler.syncWaterReminders(amount: status.amount, target: status.target)
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    /// Best-effort: a failed notification shouldn't surface as an error for
    /// what is otherwise a successful water log.
    private func notifyIfGoalJustReached(previousAmount: Int) async {
        guard let status, status.target > 0, previousAmount < status.target, status.amount >= status.target else { return }
        try? await NotificationAPI.create(title: "Goal reached!", body: "You hit your water intake goal for today.")
    }
}

import Foundation

@MainActor
final class TrackerViewModel: ObservableObject {
    @Published var painRecords: [PainEntry] = []
    @Published var averageRating: Double = 0
    @Published var waterIntake: WaterIntakeStatus?
    @Published var bloodGroup: String?
    @Published var isLoading = false
    @Published var isSaving = false
    @Published var errorMessage: String?

    func load() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        do {
            async let historyTask = PainAPI.history()
            async let waterTask = GoalAPI.waterIntake()
            async let profileTask = AuthAPI.fetchProfile()

            let (history, water, profile) = try await (historyTask, waterTask, profileTask)
            painRecords = history.painRecords
            averageRating = history.averageRating
            waterIntake = water
            bloodGroup = profile.bloodGroup
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    @discardableResult
    func logCrisis(severity: Int, triggers: [String], location: String = "Crisis") async -> Bool {
        isSaving = true
        defer { isSaving = false }
        do {
            let frequency = triggers.isEmpty ? "Unspecified" : triggers.joined(separator: ", ")
            _ = try await PainAPI.createPain(
                pain: location,
                sensation: "Reported via app",
                frequency: frequency,
                rating: severity
            )
            await load()
            return true
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }
}

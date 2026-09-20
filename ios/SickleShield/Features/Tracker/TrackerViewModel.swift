import Foundation

@MainActor
final class TrackerViewModel: ObservableObject {
    @Published var painRecords: [PainEntry] = []
    @Published var averageRating: Double = 0
    @Published var waterIntake: WaterIntakeStatus?
    @Published var bloodGroup: String?
    @Published var topTriggers: [(trigger: String, count: Int)] = []
    @Published var reminders: [Reminder] = []
    @Published var isLoading = false
    @Published var isSaving = false
    @Published var errorMessage: String?

    func load() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        do {
            async let historyTask = PainAPI.history()
            async let monthlyTask = PainAPI.history(days: 30)
            async let waterTask = GoalAPI.waterIntake()
            async let profileTask = AuthAPI.fetchProfile()
            async let remindersTask: [Reminder] = (try? await MedicationAPI.myReminders()) ?? []

            let (history, monthly, water, profile, reminderList) = try await (
                historyTask, monthlyTask, waterTask, profileTask, remindersTask
            )
            painRecords = history.painRecords
            averageRating = history.averageRating
            waterIntake = water
            bloodGroup = profile.bloodGroup
            reminders = reminderList
            topTriggers = Self.computeTopTriggers(from: monthly.painRecords)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    @discardableResult
    func logCrisis(severity: Int, triggers: [String], location: String = "Crisis", medicationTaken: String? = nil) async -> Bool {
        isSaving = true
        defer { isSaving = false }
        do {
            let frequency = triggers.isEmpty ? "Unspecified" : triggers.joined(separator: ", ")
            // `sensation` has no real UI anywhere else (always the literal
            // "Reported via app") - repurposed here to link a crisis log to
            // the medication taken for it without a backend migration. See
            // PainEntry.medicationTaken for the parsing side.
            let sensation = medicationTaken.map { "Reported via app | Medication: \($0)" } ?? "Reported via app"
            _ = try await PainAPI.createPain(
                pain: location,
                sensation: sensation,
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

    /// Splits each entry's comma-joined `frequency` field back into
    /// individual triggers and tallies the most common ones this month.
    private static func computeTopTriggers(from records: [PainEntry]) -> [(trigger: String, count: Int)] {
        var counts: [String: Int] = [:]
        for record in records {
            let triggers = record.frequency.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) }
            for trigger in triggers where !trigger.isEmpty && trigger != "Unspecified" {
                counts[trigger, default: 0] += 1
            }
        }
        return counts.sorted { $0.value > $1.value }.prefix(3).map { (trigger: $0.key, count: $0.value) }
    }
}

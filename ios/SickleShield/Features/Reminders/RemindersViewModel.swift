import Foundation

@MainActor
final class RemindersViewModel: ObservableObject {
    @Published var reminders: [Reminder] = []
    @Published var isLoading = false
    @Published var isSaving = false
    @Published var errorMessage: String?

    func load() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        do {
            reminders = try await MedicationAPI.myReminders()
            LocalNotificationScheduler.resyncMedicationReminders(reminders)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    @discardableResult
    func addReminder(name: String, type: String, amount: String, time: String) async -> Bool {
        isSaving = true
        defer { isSaving = false }
        do {
            await LocalNotificationScheduler.requestAuthorizationIfNeeded()
            try await MedicationAPI.createReminder(
                medicineName: name,
                medicineType: type,
                amount: amount,
                reminderTime: time
            )
            await load()
            return true
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }

    /// `load()` re-syncs every reminder's local notification against the
    /// freshly-fetched list, so the identifier (keyed on `reminder.id`,
    /// unchanged by this update) picks up the new time automatically.
    @discardableResult
    func updateReminderTime(_ reminder: Reminder, time: String) async -> Bool {
        do {
            try await MedicationAPI.updateReminderTime(id: reminder.id, reminderTime: time)
            await load()
            return true
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }

    func delete(_ reminder: Reminder) async {
        do {
            try await MedicationAPI.deleteReminder(id: reminder.id)
            reminders.removeAll { $0.id == reminder.id }
            LocalNotificationScheduler.cancelMedicationReminder(reminder)
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}

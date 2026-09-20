import SwiftUI

/// What kind of notifications to receive - distinct from the Notifications
/// feed (past alerts you've already gotten). All scheduling is on-device;
/// see `LocalNotificationScheduler`.
struct NotificationPreferencesView: View {
    @AppStorage("medicationRemindersEnabled") private var medicationRemindersEnabled = true
    @AppStorage("checkInRemindersEnabled") private var checkInRemindersEnabled = false
    @AppStorage("waterRemindersEnabled") private var waterRemindersEnabled = true

    @State private var reminders: [Reminder] = []

    var body: some View {
        List {
            Section {
                Toggle("Medication Reminders", isOn: $medicationRemindersEnabled)
                Toggle("Daily Check-in", isOn: $checkInRemindersEnabled)
                Toggle("Water Reminders", isOn: $waterRemindersEnabled)
            } footer: {
                Text("Water reminders send at most 3 times a day, and stop as soon as you reach that day's goal. Check-ins are a single daily nudge at 9 AM to log how you're feeling.")
            }
        }
        .navigationTitle("Notifications")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            reminders = (try? await MedicationAPI.myReminders()) ?? []
        }
        .onChange(of: medicationRemindersEnabled) { _, _ in
            LocalNotificationScheduler.resyncMedicationReminders(reminders)
        }
        .onChange(of: checkInRemindersEnabled) { _, _ in
            LocalNotificationScheduler.syncDailyCheckIn()
        }
        .onChange(of: waterRemindersEnabled) { _, _ in
            Task {
                if let status = try? await GoalAPI.waterIntake() {
                    LocalNotificationScheduler.syncWaterReminders(amount: status.amount, target: status.target)
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        NotificationPreferencesView()
    }
}

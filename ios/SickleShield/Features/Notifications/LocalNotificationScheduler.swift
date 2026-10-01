import Foundation
import UserNotifications

/// Schedules and cancels on-device notifications. There is no real push
/// infrastructure in this app - the backend collects an FCM token but never
/// uses it to trigger a push (see ios/README.md's "known scope cuts") - so
/// medication/check-in/water reminders are all scheduled locally instead.
/// Preference keys here match the `@AppStorage` keys used in
/// `NotificationPreferencesView` so both read/write the same storage.
enum LocalNotificationScheduler {
    static func requestAuthorizationIfNeeded() async {
        let center = UNUserNotificationCenter.current()
        let settings = await center.notificationSettings()
        guard settings.authorizationStatus == .notDetermined else { return }
        _ = try? await center.requestAuthorization(options: [.alert, .sound, .badge])
    }

    private static func isEnabled(_ key: String, defaultValue: Bool = true) -> Bool {
        (UserDefaults.standard.object(forKey: key) as? Bool) ?? defaultValue
    }

    // MARK: - Medication reminders

    private static func identifier(for reminder: Reminder) -> String {
        "medication-\(reminder.id)"
    }

    static func scheduleMedicationReminder(_ reminder: Reminder) {
        guard isEnabled("medicationRemindersEnabled"),
              let components = timeComponents(from: reminder.reminderTime)
        else { return }

        let content = UNMutableNotificationContent()
        content.title = "Medication reminder"
        content.body = "Time to take \(reminder.medicineName) (\(reminder.amount))."
        content.sound = .default

        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        let request = UNNotificationRequest(identifier: identifier(for: reminder), content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
    }

    static func cancelMedicationReminder(_ reminder: Reminder) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [identifier(for: reminder)])
    }

    /// Cancels and re-schedules every reminder's notification - called
    /// whenever Reminders loads, so toggling the preference or reinstalling
    /// the app stays in sync without bespoke migration logic.
    static func resyncMedicationReminders(_ reminders: [Reminder]) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: reminders.map(identifier(for:)))
        guard isEnabled("medicationRemindersEnabled") else { return }
        for reminder in reminders {
            scheduleMedicationReminder(reminder)
        }
    }

    /// Parses times like "8:00 AM" (new `DatePicker`-sourced reminders) or
    /// "20:00" (older free-text entries) into calendar components.
    private static func timeComponents(from text: String) -> DateComponents? {
        for format in ["h:mm a", "HH:mm"] {
            let formatter = DateFormatter()
            formatter.dateFormat = format
            if let date = formatter.date(from: text) {
                return Calendar.current.dateComponents([.hour, .minute], from: date)
            }
        }
        return nil
    }

    // MARK: - Daily check-in

    private static let checkInIdentifier = "daily-check-in"

    static func syncDailyCheckIn() {
        guard isEnabled("checkInRemindersEnabled", defaultValue: false) else {
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [checkInIdentifier])
            return
        }
        let content = UNMutableNotificationContent()
        content.title = "How are you feeling today?"
        content.body = "Take a moment to log a quick check-in in Sickle Shield."
        content.sound = .default

        var components = DateComponents()
        components.hour = 9
        components.minute = 0
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        let request = UNNotificationRequest(identifier: checkInIdentifier, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
    }

    // MARK: - Water reminders

    private static let waterReminderHours = [12, 16, 20]

    /// Schedules today's remaining water reminders as one-time (not
    /// repeating) notifications, so cancelling them only affects today.
    /// Called after every water log and on app foreground - naturally caps
    /// at 3/day since there are only 3 fixed hours, and stops entirely once
    /// the goal is met or the preference is off.
    static func syncWaterReminders(amount: Int, target: Int) {
        let todayKey = dayKey(for: Date())
        let allIdentifiers = waterReminderHours.indices.map { "water-reminder-\(todayKey)-\($0)" }

        guard isEnabled("waterRemindersEnabled"), target > 0, amount < target else {
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: allIdentifiers)
            return
        }

        let calendar = Calendar.current
        let now = Date()
        let remaining = target - amount

        for (index, hour) in waterReminderHours.enumerated() {
            var components = calendar.dateComponents([.year, .month, .day], from: now)
            components.hour = hour
            components.minute = 0
            guard let fireDate = calendar.date(from: components), fireDate > now else { continue }

            let content = UNMutableNotificationContent()
            content.title = "Stay hydrated"
            content.body = "You haven't reached your water goal today - \(remaining) glass\(remaining == 1 ? "" : "es") to go."
            content.sound = .default

            let fireComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: fireDate)
            let trigger = UNCalendarNotificationTrigger(dateMatching: fireComponents, repeats: false)
            let request = UNNotificationRequest(identifier: allIdentifiers[index], content: content, trigger: trigger)
            UNUserNotificationCenter.current().add(request)
        }
    }

    private static func dayKey(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }

    // MARK: - Appointment reminders

    /// Offsets that can fire before an appointment. 24h is always included
    /// by callers; 3-day/2-day are opt-in toggles shown in the add-appointment
    /// form.
    private enum AppointmentOffset: CaseIterable {
        case threeDaysBefore, twoDaysBefore, twentyFourHoursBefore

        var seconds: TimeInterval {
            switch self {
            case .threeDaysBefore: return 3 * 24 * 3600
            case .twoDaysBefore: return 2 * 24 * 3600
            case .twentyFourHoursBefore: return 24 * 3600
            }
        }

        var label: String {
            switch self {
            case .threeDaysBefore: return "3d"
            case .twoDaysBefore: return "2d"
            case .twentyFourHoursBefore: return "24h"
            }
        }
    }

    private static func appointmentIdentifier(_ appointmentId: String, offset: AppointmentOffset) -> String {
        "appointment-\(appointmentId)-\(offset.label)"
    }

    /// Merges the appointment's date with its separately-stored time string
    /// (e.g. "10:30 AM") into a single moment to compute reminder offsets from.
    private static func appointmentDateTime(date: Date, time: String) -> Date? {
        guard let timeOfDay = timeComponents(from: time) else { return nil }
        var components = Calendar.current.dateComponents([.year, .month, .day], from: date)
        components.hour = timeOfDay.hour
        components.minute = timeOfDay.minute
        return Calendar.current.date(from: components)
    }

    /// Always schedules a 24-hours-before reminder; 3-day/2-day-before are
    /// opt-in. Past-due offsets (e.g. booking an appointment less than a day
    /// out) are silently skipped rather than firing immediately.
    static func scheduleAppointmentReminders(
        appointmentId: String,
        hospitalName: String,
        date: Date,
        time: String,
        includeThreeDaysBefore: Bool,
        includeTwoDaysBefore: Bool
    ) {
        guard let appointmentMoment = appointmentDateTime(date: date, time: time) else { return }
        let now = Date()

        var offsetsToSchedule: [AppointmentOffset] = [.twentyFourHoursBefore]
        if includeThreeDaysBefore { offsetsToSchedule.append(.threeDaysBefore) }
        if includeTwoDaysBefore { offsetsToSchedule.append(.twoDaysBefore) }

        for offset in offsetsToSchedule {
            let fireDate = appointmentMoment.addingTimeInterval(-offset.seconds)
            guard fireDate > now else { continue }

            let content = UNMutableNotificationContent()
            content.title = "Upcoming appointment"
            content.body = "You have an appointment at \(hospitalName) on \(Self.appointmentDateFormatter.string(from: appointmentMoment)) at \(time)."
            content.sound = .default

            let fireComponents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: fireDate)
            let trigger = UNCalendarNotificationTrigger(dateMatching: fireComponents, repeats: false)
            let request = UNNotificationRequest(identifier: appointmentIdentifier(appointmentId, offset: offset), content: content, trigger: trigger)
            UNUserNotificationCenter.current().add(request)
        }
    }

    static func cancelAppointmentReminders(appointmentId: String) {
        let identifiers = AppointmentOffset.allCases.map { appointmentIdentifier(appointmentId, offset: $0) }
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: identifiers)
    }

    private static let appointmentDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        return formatter
    }()
}

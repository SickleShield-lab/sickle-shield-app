import Foundation

struct Reminder: Codable, Identifiable {
    let id: String
    let userId: String
    let medicineName: String
    let medicineType: String
    let amount: String
    let reminderTime: String
    let createdAt: Date
    let updatedAt: Date
}

struct CreateReminderRequest: Encodable {
    let medicineName: String
    let medicineType: String
    let amount: String
    let reminderTime: String
}

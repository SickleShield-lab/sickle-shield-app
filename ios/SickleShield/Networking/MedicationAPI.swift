import Foundation

enum MedicationAPI {
    // MARK: - Reminders

    static func createReminder(
        medicineName: String,
        medicineType: String,
        amount: String,
        reminderTime: String
    ) async throws {
        let body = CreateReminderRequest(
            medicineName: medicineName,
            medicineType: medicineType,
            amount: amount,
            reminderTime: reminderTime
        )
        try await APIClient.shared.requestVoid("medication/reminder/create", method: "POST", body: body)
    }

    static func myReminders() async throws -> [Reminder] {
        try await APIClient.shared.request("medication/reminders/my-reminders", method: "GET")
    }

    static func updateReminderTime(id: String, reminderTime: String) async throws {
        let body = UpdateReminderTimeRequest(reminderTime: reminderTime)
        try await APIClient.shared.requestVoid("medication/reminders/\(id)", method: "PATCH", body: body)
    }

    static func deleteReminder(id: String) async throws {
        try await APIClient.shared.requestVoid("medication/reminders/\(id)", method: "DELETE")
    }

    // MARK: - Reports

    static func myReports() async throws -> [Report] {
        try await APIClient.shared.request("medication/reports/my-reports", method: "GET")
    }

    /// The backend expects report metadata as a JSON string in a "bodyData"
    /// form field alongside the file (see parseBodyData.ts) rather than as
    /// separate form fields.
    static func uploadReport(
        reportName: String,
        date: Date,
        fileData: Data,
        fileName: String,
        mimeType: String
    ) async throws {
        struct Metadata: Encodable {
            let reportName: String
            let date: String
        }
        let formatter = ISO8601DateFormatter()
        let metadata = Metadata(reportName: reportName, date: formatter.string(from: date))
        let jsonData = try JSONEncoder().encode(metadata)
        let jsonString = String(data: jsonData, encoding: .utf8) ?? "{}"

        try await APIClient.shared.uploadVoid(
            "medication/report/upload",
            fields: ["bodyData": jsonString],
            fileFieldName: "reportFile",
            fileName: fileName,
            fileData: fileData,
            mimeType: mimeType
        )
    }

    static func deleteReport(id: String) async throws {
        try await APIClient.shared.requestVoid("medication/reports/\(id)", method: "DELETE")
    }
}

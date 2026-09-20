import Foundation

private struct CreateNotificationRequest: Encodable {
    let title: String
    let body: String
}

enum NotificationAPI {
    /// The backend returns a 404 when the user has zero notifications rather
    /// than an empty array, so an empty list and a "not found" are the same
    /// thing here - callers should treat that 404 as "no notifications."
    static func all() async throws -> [AppNotification] {
        try await APIClient.shared.request("notifications", method: "GET")
    }

    static func create(title: String, body: String) async throws {
        try await APIClient.shared.requestVoid(
            "notifications",
            method: "POST",
            body: CreateNotificationRequest(title: title, body: body)
        )
    }
}

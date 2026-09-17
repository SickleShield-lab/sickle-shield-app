import Foundation

enum NotificationAPI {
    /// The backend returns a 404 when the user has zero notifications rather
    /// than an empty array, so an empty list and a "not found" are the same
    /// thing here - callers should treat that 404 as "no notifications."
    static func all() async throws -> [AppNotification] {
        try await APIClient.shared.request("notifications", method: "GET")
    }
}

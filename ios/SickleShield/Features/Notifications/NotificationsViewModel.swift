import Foundation

@Observable
@MainActor
final class NotificationsViewModel {
    var notifications: [AppNotification] = []
    var isLoading = false
    var errorMessage: String?

    func load() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        do {
            notifications = try await NotificationAPI.all()
        } catch APIError.server(_, let statusCode) where statusCode == 404 {
            // The backend returns 404 for "zero notifications" instead of an empty array.
            notifications = []
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}

import Foundation

@MainActor
final class SessionStore: ObservableObject {
    @Published var currentUser: User?
    @Published var isAuthenticated: Bool

    init() {
        isAuthenticated = KeychainHelper.shared.token != nil
    }

    func setSession(token: String, user: User) {
        KeychainHelper.shared.token = token
        currentUser = user
        isAuthenticated = true
    }

    func refreshProfile() async {
        guard isAuthenticated else { return }
        do {
            currentUser = try await AuthAPI.fetchProfile()
        } catch APIError.unauthorized {
            logOut()
        } catch {
            // Keep the last known profile; the screen that triggered this
            // refresh is responsible for surfacing its own error state.
        }
    }

    func logOut() {
        KeychainHelper.shared.clear()
        currentUser = nil
        isAuthenticated = false
    }
}

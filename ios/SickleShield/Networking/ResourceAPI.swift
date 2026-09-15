import Foundation

enum ResourceAPI {
    static func all() async throws -> EduResourceListResponse {
        try await APIClient.shared.request("resource/all", method: "GET")
    }
}

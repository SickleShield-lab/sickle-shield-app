import Foundation

enum ResourceAPI {
    static func all() async throws -> EduResourceListResponse {
        try await APIClient.shared.request("resource/all", method: "GET")
    }

    static func single(id: String) async throws -> EduResource {
        try await APIClient.shared.request("resource/\(id)", method: "GET")
    }
}

import Foundation

enum PainAPI {
    static func createPain(pain: String, sensation: String, frequency: String, rating: Int) async throws -> PainEntry {
        let body = CreatePainRequest(pain: pain, sensation: sensation, frequency: frequency, rating: rating)
        return try await APIClient.shared.request("pain/create", method: "POST", body: body)
    }

    static func history(days: Int = 7) async throws -> PainHistoryResponse {
        try await APIClient.shared.request("pain/my/pains", method: "GET", query: ["days": String(days)])
    }
}

import Foundation

enum MoodAPI {
    static func log(mood: String, note: String? = nil) async throws -> MoodEntry {
        let body = LogMoodRequest(mood: mood, note: note)
        return try await APIClient.shared.request("mood/log", method: "POST", body: body)
    }

    static func myMoods(days: Int = 30) async throws -> [MoodEntry] {
        try await APIClient.shared.request("mood/my-moods", method: "GET", query: ["days": String(days)])
    }
}

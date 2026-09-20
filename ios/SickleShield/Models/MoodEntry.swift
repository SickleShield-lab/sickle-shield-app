import Foundation

struct MoodEntry: Codable, Identifiable {
    let id: String
    let userId: String
    let mood: String
    let note: String?
    let loggedAt: Date
    let createdAt: Date
    let updatedAt: Date
}

struct LogMoodRequest: Encodable {
    let mood: String
    var note: String?
}

import Foundation

struct AppNotification: Codable, Identifiable {
    let id: String
    let userId: String
    let title: String
    let body: String
    let read: Bool
    let createdAt: Date
    let updatedAt: Date
}

import Foundation

struct Report: Codable, Identifiable {
    let id: String
    let userId: String
    let reportName: String
    let date: Date
    let reportFile: String
    let createdAt: Date
    let updatedAt: Date
}

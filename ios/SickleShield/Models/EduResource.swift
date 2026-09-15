import Foundation

struct EduResource: Codable, Identifiable {
    let id: String
    let resourceImages: [String]
    let title: String
    let subTitle: String
    let description: String
}

struct EduResourceListResponse: Codable {
    let totalCount: Int
    let totalPages: Int
    let currentPage: Int
    let resources: [EduResource]
}

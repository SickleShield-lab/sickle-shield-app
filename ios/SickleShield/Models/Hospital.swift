import Foundation

struct Hospital: Codable, Identifiable {
    let id: String
    let hospitalName: String
    let userId: String
    let location: String
    let hospitalImages: String?
    let createdAt: Date
    let updatedAt: Date
}

struct HospitalListResponse: Codable {
    let totalCount: Int
    let totalPages: Int
    let currentPage: Int
    let hospitals: [Hospital]
}

struct CreateHospitalRequest: Encodable {
    let hospitalName: String
    let location: String
}

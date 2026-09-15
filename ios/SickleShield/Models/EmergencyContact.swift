import Foundation

struct EmergencyContact: Codable, Identifiable {
    let id: String
    let userId: String
    let contactName: String
    let contactNumber: String
    let createdAt: Date
    let updatedAt: Date
}

struct EmergencyContactListResponse: Codable {
    let totalCount: Int
    let totalPages: Int
    let currentPage: Int
    let contacts: [EmergencyContact]
}

struct CreateEmergencyContactRequest: Encodable {
    let contactName: String
    let contactNumber: String
}

import Foundation

enum HospitalAPI {
    static func emergencyContacts() async throws -> EmergencyContactListResponse {
        try await APIClient.shared.request("hospital/emergency/contacts", method: "GET")
    }

    static func createEmergencyContact(name: String, number: String) async throws {
        let body = CreateEmergencyContactRequest(contactName: name, contactNumber: number)
        try await APIClient.shared.requestVoid("hospital/emergency-contact/create", method: "POST", body: body)
    }

    static func deleteEmergencyContact(id: String) async throws {
        try await APIClient.shared.requestVoid("hospital/emergency-contact/delete/\(id)", method: "DELETE")
    }
}

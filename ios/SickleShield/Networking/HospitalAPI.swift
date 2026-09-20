import Foundation

enum HospitalAPI {
    static func all() async throws -> HospitalListResponse {
        try await APIClient.shared.request("hospital/all", method: "GET")
    }

    static func create(hospitalName: String, location: String, emergencyContacts: [String]) async throws -> Hospital {
        let payload = CreateHospitalRequest(hospitalName: hospitalName, location: location, emergencyContacts: emergencyContacts)
        return try await APIClient.shared.request("hospital/create", method: "POST", body: payload)
    }

    static func update(id: String, hospitalName: String, location: String, emergencyContacts: [String]) async throws -> Hospital {
        let payload = CreateHospitalRequest(hospitalName: hospitalName, location: location, emergencyContacts: emergencyContacts)
        return try await APIClient.shared.request("hospital/\(id)", method: "PATCH", body: payload)
    }

    static func delete(id: String) async throws {
        try await APIClient.shared.requestVoid("hospital/\(id)", method: "DELETE")
    }

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

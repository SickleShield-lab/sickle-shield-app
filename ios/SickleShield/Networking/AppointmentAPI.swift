import Foundation

enum AppointmentAPI {
    static func myAppointments() async throws -> AppointmentListResponse {
        try await APIClient.shared.request("appointment/my-appointments", method: "GET")
    }

    static func create(hospitalId: String, doctorName: String?, date: Date, shift: String, time: String) async throws -> Appointment {
        let body = CreateAppointmentRequest(doctorName: doctorName, date: date, shift: shift, time: time)
        return try await APIClient.shared.request("appointment/create/\(hospitalId)", method: "POST", body: body)
    }

    static func delete(id: String) async throws {
        try await APIClient.shared.requestVoid("appointment/\(id)", method: "DELETE")
    }
}

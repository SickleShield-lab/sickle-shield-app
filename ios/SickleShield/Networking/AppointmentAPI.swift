import Foundation

enum AppointmentAPI {
    static func myAppointments() async throws -> AppointmentListResponse {
        try await APIClient.shared.request("appointment/my-appointments", method: "GET")
    }
}

import Foundation

struct Appointment: Codable, Identifiable {
    let id: String
    let userId: String
    let hospitalId: String
    let doctorName: String?
    let date: Date
    let shift: String
    let time: String
    let status: String
}

struct AppointmentListResponse: Codable {
    let totalCount: Int
    let totalPages: Int
    let currentPage: Int
    let appointments: [Appointment]
}

struct CreateAppointmentRequest: Encodable {
    var doctorName: String?
    let date: Date
    let shift: String
    let time: String
}

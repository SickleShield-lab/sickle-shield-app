import Foundation

struct Appointment: Codable, Identifiable {
    let id: String
    let userId: String
    let hospitalId: String
    let doctorName: String?
    let type: String?
    let date: Date
    let shift: String
    let time: String
    let status: String

    /// A short relative label ("Today", "Tomorrow", "in 5 days") based on
    /// calendar-day difference, ignoring the appointment's time-of-day.
    var countdownText: String {
        let calendar = Calendar.current
        let days = calendar.dateComponents([.day], from: calendar.startOfDay(for: Date()), to: calendar.startOfDay(for: date)).day ?? 0
        switch days {
        case ..<0: return "Past"
        case 0: return "Today"
        case 1: return "Tomorrow"
        default: return "in \(days) days"
        }
    }
}

struct AppointmentListResponse: Codable {
    let totalCount: Int
    let totalPages: Int
    let currentPage: Int
    let appointments: [Appointment]
}

struct CreateAppointmentRequest: Encodable {
    var doctorName: String?
    var type: String?
    let date: Date
    let shift: String
    let time: String
}

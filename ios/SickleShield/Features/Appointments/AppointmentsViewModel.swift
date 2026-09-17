import Foundation

@Observable
@MainActor
final class AppointmentsViewModel {
    var appointments: [Appointment] = []
    var hospitals: [Hospital] = []
    var isLoading = false
    var errorMessage: String?

    func load() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        async let appointmentsTask = AppointmentAPI.myAppointments()
        async let hospitalsTask = HospitalAPI.all()
        do {
            appointments = try await appointmentsTask.appointments
            hospitals = try await hospitalsTask.hospitals
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    @discardableResult
    func addAppointment(hospitalId: String, doctorName: String, date: Date, shift: String, time: String) async -> Bool {
        do {
            let appointment = try await AppointmentAPI.create(
                hospitalId: hospitalId,
                doctorName: doctorName.isEmpty ? nil : doctorName,
                date: date,
                shift: shift,
                time: time
            )
            appointments.insert(appointment, at: 0)
            return true
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }

    func delete(_ appointment: Appointment) async {
        do {
            try await AppointmentAPI.delete(id: appointment.id)
            appointments.removeAll { $0.id == appointment.id }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func hospitalName(for appointment: Appointment) -> String {
        hospitals.first { $0.id == appointment.hospitalId }?.hospitalName ?? "Hospital"
    }
}

import Foundation

@MainActor
final class ExploreViewModel: ObservableObject {
    @Published var user: User?
    @Published var nextAppointment: Appointment?
    @Published var resources: [EduResource] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    func load() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        do {
            async let userTask = AuthAPI.fetchProfile()
            async let appointmentsTask = AppointmentAPI.myAppointments()
            async let resourcesTask = ResourceAPI.all()

            let (fetchedUser, appointments, resourceList) = try await (userTask, appointmentsTask, resourcesTask)
            user = fetchedUser
            nextAppointment = appointments.appointments.first
            resources = resourceList.resources
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}

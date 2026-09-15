import Foundation

@MainActor
final class ExploreViewModel: ObservableObject {
    @Published var user: User?
    @Published var nextAppointment: Appointment?
    @Published var resources: [EduResource] = []
    @Published var riskAssessment: CrisisRiskAssessment?
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let locationManager = LocationManager()
    private let healthKitManager = HealthKitManager()

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

        await loadRiskAssessment()
    }

    /// Best-effort: a missing weather reading or pain history shouldn't block
    /// the rest of the screen, so failures here are swallowed rather than
    /// surfaced as the page-level error.
    private func loadRiskAssessment() async {
        async let historyTask: PainHistoryResponse? = try? PainAPI.history(days: 7)
        async let waterTask: WaterIntakeStatus? = try? GoalAPI.waterIntake()
        let (history, water) = await (historyTask, waterTask)

        var weather: WeatherSnapshot?
        if let location = try? await locationManager.requestLocation() {
            weather = try? await WeatherAPI.currentWeather(
                latitude: location.coordinate.latitude,
                longitude: location.coordinate.longitude
            )
        }

        let vitals = await healthKitManager.latestVitals()

        riskAssessment = RiskScoreEngine.assess(
            painRecords: history?.painRecords ?? [],
            averageRating: history?.averageRating ?? 0,
            waterIntake: water,
            weather: weather,
            vitals: vitals
        )

        SharedStore.writeWidgetSnapshot(
            painScore: Double(user?.painManager ?? 0),
            water: water.map { "\($0.amount)/\($0.target)" } ?? "-/-",
            updatedAt: Date()
        )
        WidgetReloader.reloadAll()
    }
}

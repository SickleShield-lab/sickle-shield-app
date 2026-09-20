import Foundation

/// A single row in "Your Day" - merges the day's Pain/Weight/Mood logs into
/// one chronological list. Water and medication-taken events are left out:
/// water intake is tracked as one running total with no per-event log, and
/// reminders have no "taken" history at all - surfacing either here would
/// mean fabricating timestamps that don't exist (known scope cut, see
/// ios/README.md's "Known scope cuts" convention).
struct TodayTimelineEntry: Identifiable {
    let id: String
    let date: Date
    let text: String
}

@MainActor
final class TodayViewModel: ObservableObject {
    @Published var user: User?
    @Published var nextAppointment: Appointment?
    @Published var hospitals: [Hospital] = []
    @Published var resources: [EduResource] = PlaceholderResources.all
    @Published var riskAssessment: CrisisRiskAssessment?
    @Published var waterStatus: WaterIntakeStatus?
    @Published var reminderCount: Int?
    @Published var todayTimeline: [TodayTimelineEntry] = []
    @Published var hasUnreadNotifications = false
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let locationManager = LocationManager()
    private let healthKitManager = HealthKitManager()
    private var recentPainHistory: PainHistoryResponse?

    func load() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        do {
            async let userTask = AuthAPI.fetchProfile()
            async let appointmentsTask = AppointmentAPI.myAppointments()
            async let hospitalsTask = HospitalAPI.all()
            async let resourcesTask = ResourceAPI.all()
            async let waterTask = GoalAPI.waterIntake()
            async let remindersTask = MedicationAPI.myReminders()
            async let historyTask = PainAPI.history(days: 7)
            async let weightTask = GoalAPI.weightHistory(days: 1)
            async let moodTask = MoodAPI.myMoods(days: 1)
            async let notificationsTask: [AppNotification]? = try? await NotificationAPI.all()

            let (fetchedUser, appointments, hospitalList, resourceList, water, reminders, history, weightEntries, moodEntries, notifications) = try await (
                userTask, appointmentsTask, hospitalsTask, resourcesTask, waterTask, remindersTask, historyTask, weightTask, moodTask, notificationsTask
            )
            user = fetchedUser
            nextAppointment = appointments.appointments.first
            hospitals = hospitalList.hospitals
            resources = resourceList.resources.isEmpty ? PlaceholderResources.all : resourceList.resources
            waterStatus = water
            reminderCount = reminders.count
            recentPainHistory = history
            hasUnreadNotifications = notifications?.contains { !$0.read } ?? false

            let todayPain = history.painRecords
                .filter { Calendar.current.isDateInToday($0.createdAt) }
                .map { TodayTimelineEntry(id: "pain-\($0.id)", date: $0.createdAt, text: "Pain \($0.rating)/10 logged\($0.pain.isEmpty ? "" : " · \($0.pain)")") }
            let todayWeight = weightEntries
                .filter { Calendar.current.isDateInToday($0.loggedAt) }
                .map { TodayTimelineEntry(id: "weight-\($0.id)", date: $0.loggedAt, text: "Weight logged: \(String(format: "%.1f", $0.weight)) kg") }
            let todayMood = moodEntries
                .filter { Calendar.current.isDateInToday($0.loggedAt) }
                .map { TodayTimelineEntry(id: "mood-\($0.id)", date: $0.loggedAt, text: "Mood logged: \($0.mood.capitalized)") }

            todayTimeline = (todayPain + todayWeight + todayMood)
                .sorted { $0.date > $1.date }
                .prefix(5)
                .map { $0 }
        } catch {
            errorMessage = error.localizedDescription
        }

        await loadRiskAssessment()
    }

    /// Best-effort: a missing weather reading shouldn't block the rest of
    /// the screen, so failures here are swallowed rather than surfaced as
    /// the page-level error.
    private func loadRiskAssessment() async {
        var weather: WeatherSnapshot?
        if let location = try? await locationManager.requestLocation() {
            weather = try? await WeatherAPI.currentWeather(
                latitude: location.coordinate.latitude,
                longitude: location.coordinate.longitude
            )
        }

        let vitals = await healthKitManager.latestVitals()

        riskAssessment = RiskScoreEngine.assess(
            painRecords: recentPainHistory?.painRecords ?? [],
            averageRating: recentPainHistory?.averageRating ?? 0,
            waterIntake: waterStatus,
            weather: weather,
            vitals: vitals
        )

        SharedStore.writeWidgetSnapshot(
            painScore: Double(user?.painManager ?? 0),
            water: waterStatus.map { "\($0.amount)/\($0.target)" } ?? "-/-",
            updatedAt: Date()
        )
        WidgetReloader.reloadAll()
    }

    func hospitalName(for appointment: Appointment) -> String {
        hospitals.first { $0.id == appointment.hospitalId }?.hospitalName ?? "Hospital"
    }
}

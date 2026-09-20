import CoreLocation
import Foundation

@MainActor
final class EmergencyViewModel: ObservableObject {
    @Published var contacts: [EmergencyContact] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var sosStatus = "Tap to share your live location by text"
    @Published var isSendingSOS = false
    @Published var pendingSOSURL: URL?
    @Published var isCrisisActive = false
    @Published var crisisStartedAt: Date?
    @Published var crisisSeverity: Int?

    private let locationManager = LocationManager()

    func load() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        do {
            let response = try await HospitalAPI.emergencyContacts()
            contacts = response.contacts
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func delete(_ contact: EmergencyContact) async {
        do {
            try await HospitalAPI.deleteEmergencyContact(id: contact.id)
            contacts.removeAll { $0.id == contact.id }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func triggerSOS(to selectedContacts: [EmergencyContact]) async {
        guard !isSendingSOS else { return }
        guard !selectedContacts.isEmpty else {
            sosStatus = "Select at least one contact first."
            return
        }
        isSendingSOS = true
        sosStatus = "Getting your location..."
        defer { isSendingSOS = false }
        do {
            let location = try await locationManager.requestLocation()
            let mapsLink = "https://maps.google.com/?q=\(location.coordinate.latitude),\(location.coordinate.longitude)"

            // "Black box": pull the last day of vitals so whoever receives this
            // has real context, not just a pin on a map.
            let blackBox = await Self.blackBoxSummary()

            let message = "SOS from Sickle Shield - I need help.\nLocation: \(mapsLink)\(blackBox)"
            let numbers = selectedContacts.map(\.contactNumber).joined(separator: ",")

            guard
                let encodedBody = message.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
                let url = URL(string: "sms:\(numbers)&body=\(encodedBody)")
            else {
                sosStatus = "Couldn't prepare the message. Try again."
                return
            }
            pendingSOSURL = url
            sosStatus = "Opening Messages with your location and recent vitals..."

            if #available(iOS 16.1, *) {
                let recentSeverity = (try? await PainAPI.history(days: 1))?.painRecords.last?.rating ?? 5
                CrisisLiveActivityController.start(severity: recentSeverity, contactName: selectedContacts.first?.contactName ?? "your contacts")
                isCrisisActive = true
            }
        } catch let error as CLError where error.code == .locationUnknown {
            sosStatus = "Couldn't determine your location. In the Simulator, set one via Features > Location > Custom Location, then try again."
        } catch {
            sosStatus = error.localizedDescription
        }
    }

    /// Starts the full Crisis Mode experience: logs a real pain entry so the
    /// crisis shows up in Tracker history like any other, and uses that
    /// entry's `createdAt` as the timer's start time rather than a separate
    /// local-only timestamp.
    @discardableResult
    func startCrisisMode(severity: Int) async -> Bool {
        do {
            let entry = try await PainAPI.createPain(
                pain: "Crisis",
                sensation: "Reported via app",
                frequency: "Crisis Mode",
                rating: severity
            )
            crisisSeverity = severity
            crisisStartedAt = entry.createdAt
            isCrisisActive = true
            if #available(iOS 16.1, *) {
                CrisisLiveActivityController.start(severity: severity, contactName: contacts.first?.contactName ?? "your contacts")
            }
            return true
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }

    func endCrisis() {
        if #available(iOS 16.1, *) {
            CrisisLiveActivityController.endAll()
        }
        isCrisisActive = false
        crisisStartedAt = nil
        crisisSeverity = nil
    }

    /// Best-effort summary of the last 24h of pain logs and today's water
    /// intake. Failures here must never block the SOS itself - an SOS with
    /// just a location is still far better than none at all.
    private static func blackBoxSummary() async -> String {
        async let historyTask: PainHistoryResponse? = try? PainAPI.history(days: 1)
        async let waterTask: WaterIntakeStatus? = try? GoalAPI.waterIntake()
        let (history, water) = await (historyTask, waterTask)

        var lines: [String] = []
        if let history, !history.painRecords.isEmpty {
            let latest = history.painRecords.max(by: { $0.createdAt < $1.createdAt })
            lines.append("Pain crises in last 24h: \(history.painRecords.count) (avg severity \(String(format: "%.1f", history.averageRating)))")
            if let latest {
                lines.append("Most recent: \(latest.rating)/10, \(latest.pain), logged \(Self.relativeTime(latest.createdAt))")
            }
        }
        if let water {
            lines.append("Water today: \(water.amount)/\(water.target) glasses")
        }
        guard !lines.isEmpty else { return "" }
        return "\n\n" + lines.joined(separator: "\n")
    }

    private static func relativeTime(_ date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .short
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}

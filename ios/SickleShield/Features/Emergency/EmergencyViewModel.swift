import Foundation

@MainActor
final class EmergencyViewModel: ObservableObject {
    @Published var contacts: [EmergencyContact] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var sosStatus = "Tap to share your live location by text"
    @Published var isSendingSOS = false
    @Published var pendingSOSURL: URL?

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

    func triggerSOS() async {
        guard !isSendingSOS else { return }
        guard !contacts.isEmpty else {
            sosStatus = "Add an emergency contact first."
            return
        }
        isSendingSOS = true
        sosStatus = "Getting your location..."
        defer { isSendingSOS = false }
        do {
            let location = try await locationManager.requestLocation()
            let mapsLink = "https://maps.google.com/?q=\(location.coordinate.latitude),\(location.coordinate.longitude)"
            let message = "This is an emergency alert from Sickle Shield. I need help - my location: \(mapsLink)"
            let numbers = contacts.map(\.contactNumber).joined(separator: ",")

            guard
                let encodedBody = message.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
                let url = URL(string: "sms:\(numbers)&body=\(encodedBody)")
            else {
                sosStatus = "Couldn't prepare the message. Try again."
                return
            }
            pendingSOSURL = url
            sosStatus = "Opening Messages with your location..."
        } catch {
            sosStatus = error.localizedDescription
        }
    }
}

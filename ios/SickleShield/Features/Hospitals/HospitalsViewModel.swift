import Foundation

@Observable
@MainActor
final class HospitalsViewModel {
    var hospitals: [Hospital] = []
    var isLoading = false
    var errorMessage: String?

    func load() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        do {
            hospitals = try await HospitalAPI.all().hospitals
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    /// `HospitalFormSheet` owns the create/update network call itself (same
    /// pattern as `EditProfileView`/`ChangePasswordView`) and just reports
    /// back the saved result here.
    func upsert(_ hospital: Hospital) {
        if let index = hospitals.firstIndex(where: { $0.id == hospital.id }) {
            hospitals[index] = hospital
        } else {
            hospitals.insert(hospital, at: 0)
        }
    }

    func delete(_ hospital: Hospital) async {
        do {
            try await HospitalAPI.delete(id: hospital.id)
            hospitals.removeAll { $0.id == hospital.id }
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}

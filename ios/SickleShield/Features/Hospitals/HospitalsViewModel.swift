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

    @discardableResult
    func addHospital(name: String, location: String) async -> Bool {
        do {
            let hospital = try await HospitalAPI.create(hospitalName: name, location: location)
            hospitals.insert(hospital, at: 0)
            return true
        } catch {
            errorMessage = error.localizedDescription
            return false
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

import Foundation

@Observable
@MainActor
final class EducationalResourcesViewModel {
    var resources: [EduResource] = []
    var isLoading = false
    var errorMessage: String?

    func load() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        do {
            resources = try await ResourceAPI.all().resources
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}

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
            let fetched = try await ResourceAPI.all().resources
            resources = fetched.isEmpty ? PlaceholderResources.all : fetched
        } catch {
            // Fall back to placeholders rather than a dead-end error state -
            // education content should never look broken.
            resources = PlaceholderResources.all
        }
    }
}

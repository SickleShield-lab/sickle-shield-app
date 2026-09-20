import Foundation

@MainActor
final class ReportsViewModel: ObservableObject {
    @Published var reports: [Report] = []
    @Published var isLoading = false
    @Published var isSaving = false
    @Published var errorMessage: String?

    func load() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        do {
            reports = try await MedicationAPI.myReports()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    @discardableResult
    func upload(name: String, fileData: Data, fileName: String, mimeType: String) async -> Bool {
        isSaving = true
        errorMessage = nil
        defer { isSaving = false }
        do {
            try await MedicationAPI.uploadReport(
                reportName: name,
                date: Date(),
                fileData: fileData,
                fileName: fileName,
                mimeType: mimeType
            )
            await load()
            return true
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }

    func delete(_ report: Report) async {
        do {
            try await MedicationAPI.deleteReport(id: report.id)
            reports.removeAll { $0.id == report.id }
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}

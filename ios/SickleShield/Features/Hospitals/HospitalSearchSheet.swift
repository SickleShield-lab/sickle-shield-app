import SwiftUI
import MapKit

struct HospitalSearchResult: Identifiable {
    let id = UUID()
    let name: String
    let address: String
}

@MainActor
@Observable
final class HospitalSearchViewModel {
    var query = ""
    var results: [HospitalSearchResult] = []
    var isSearching = false
    var errorMessage: String?

    private let locationManager = LocationManager()

    /// Real hospital search via MapKit's points-of-interest search - not
    /// limited to any one country, works anywhere Apple Maps has coverage
    /// (e.g. searching "London" or a hospital name in the UK). Biased
    /// toward the user's current location when available, but that's a
    /// hint, not a requirement - a named search like "Manchester Royal
    /// Infirmary" still works without location access.
    func search() async {
        let trimmed = query.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return }
        isSearching = true
        errorMessage = nil
        defer { isSearching = false }

        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = trimmed
        request.pointOfInterestFilter = MKPointOfInterestFilter(including: [.hospital])
        if let location = try? await locationManager.requestLocation() {
            request.region = MKCoordinateRegion(
                center: location.coordinate,
                latitudinalMeters: 50_000,
                longitudinalMeters: 50_000
            )
        }

        do {
            let response = try await MKLocalSearch(request: request).start()
            results = response.mapItems.map { item in
                HospitalSearchResult(
                    name: item.name ?? trimmed,
                    address: Self.formattedAddress(for: item.placemark)
                )
            }
            if results.isEmpty {
                errorMessage = "No hospitals found for \"\(trimmed)\". Try a city or hospital name."
            }
        } catch {
            errorMessage = "Couldn't search for hospitals. Check your connection and try again."
        }
    }

    private static func formattedAddress(for placemark: MKPlacemark) -> String {
        [placemark.thoroughfare, placemark.locality, placemark.administrativeArea, placemark.country]
            .compactMap { $0 }
            .joined(separator: ", ")
    }
}

struct HospitalSearchSheet: View {
    let onSelect: (HospitalSearchResult) -> Void
    @State private var viewModel = HospitalSearchViewModel()
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            List {
                if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                        .foregroundStyle(SSColor.textSecondary)
                }
                ForEach(viewModel.results) { result in
                    Button {
                        onSelect(result)
                        dismiss()
                    } label: {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(result.name)
                                .foregroundStyle(SSColor.textPrimary)
                            if !result.address.isEmpty {
                                Text(result.address)
                                    .font(.caption)
                                    .foregroundStyle(SSColor.textSecondary)
                            }
                        }
                    }
                }
            }
            .overlay {
                if viewModel.isSearching {
                    ProgressView()
                }
            }
            .searchable(text: $viewModel.query, prompt: "Hospital name or city, e.g. \"London\"")
            .onSubmit(of: .search) {
                Task { await viewModel.search() }
            }
            .navigationTitle("Search Hospitals")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }
}

#Preview {
    HospitalSearchSheet { _ in }
}

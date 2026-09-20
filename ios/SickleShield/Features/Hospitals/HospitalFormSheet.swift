import SwiftUI
import CoreLocation

/// Handles both adding and editing a hospital - pass `existingHospital` to
/// edit, or leave it nil to create a new one.
struct HospitalFormSheet: View {
    let existingHospital: Hospital?
    let onSave: (Hospital) -> Void
    @Environment(\.dismiss) private var dismiss

    @State private var name: String
    @State private var location: String
    @State private var scdUnitPhone: String
    @State private var isSaving = false
    @State private var isLocating = false
    @State private var showHospitalSearch = false
    @State private var errorMessage: String?

    private let locationManager = LocationManager()

    init(existingHospital: Hospital? = nil, onSave: @escaping (Hospital) -> Void) {
        self.existingHospital = existingHospital
        self.onSave = onSave
        _name = State(initialValue: existingHospital?.hospitalName ?? "")
        _location = State(initialValue: existingHospital?.location ?? "")
        _scdUnitPhone = State(initialValue: existingHospital?.emergencyContacts.first ?? "")
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    hospitalIcon
                }
                .listRowBackground(Color.clear)

                if existingHospital == nil {
                    Section {
                        Button {
                            showHospitalSearch = true
                        } label: {
                            Label("Search Hospitals", systemImage: "magnifyingglass")
                        }
                    } footer: {
                        Text("Search for a real hospital by name or city (e.g. a UK hospital), or enter details manually below.")
                    }
                }

                Section("Hospital") {
                    TextField("Hospital name", text: $name)
                    HStack {
                        TextField("Location", text: $location)
                        Button {
                            Task { await useCurrentLocation() }
                        } label: {
                            if isLocating {
                                ProgressView()
                            } else {
                                Image(systemName: "location.fill")
                            }
                        }
                        .disabled(isLocating)
                        .buttonStyle(.borderless)
                    }
                }

                Section {
                    TextField("Phone number", text: $scdUnitPhone)
                        .keyboardType(.phonePad)
                } header: {
                    Text("Sickle Cell Unit")
                } footer: {
                    Text("Optional - if set, this number is saved with the hospital's details.")
                }

                if let errorMessage {
                    Text(errorMessage)
                        .foregroundStyle(.red)
                }
            }
            .navigationTitle(existingHospital == nil ? "Add hospital" : "Edit hospital")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button {
                        Task { await save() }
                    } label: {
                        if isSaving {
                            ProgressView()
                        } else {
                            Text("Save")
                        }
                    }
                    .disabled(isSaving || name.isEmpty || location.isEmpty)
                }
            }
            .sheet(isPresented: $showHospitalSearch) {
                HospitalSearchSheet { result in
                    name = result.name
                    location = result.address
                }
            }
        }
    }

    private var hospitalIcon: some View {
        HStack {
            Spacer()
            Image(systemName: "cross.case.fill")
                .font(.system(size: 30))
                .foregroundStyle(SSColor.brand)
                .frame(width: 80, height: 80)
                .background(SSColor.surfaceSecondary)
                .clipShape(Circle())
            Spacer()
        }
    }

    private func useCurrentLocation() async {
        isLocating = true
        errorMessage = nil
        defer { isLocating = false }
        do {
            let coordinate = try await locationManager.requestLocation()
            let placemarks = try await CLGeocoder().reverseGeocodeLocation(coordinate)
            if let placemark = placemarks.first {
                location = [placemark.name, placemark.locality, placemark.administrativeArea]
                    .compactMap { $0 }
                    .joined(separator: ", ")
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func save() async {
        isSaving = true
        errorMessage = nil
        defer { isSaving = false }

        let trimmedPhone = scdUnitPhone.trimmingCharacters(in: .whitespaces)
        let contacts = trimmedPhone.isEmpty ? [] : [trimmedPhone]

        do {
            let saved: Hospital
            if let existingHospital {
                saved = try await HospitalAPI.update(
                    id: existingHospital.id,
                    hospitalName: name,
                    location: location,
                    emergencyContacts: contacts
                )
            } else {
                saved = try await HospitalAPI.create(
                    hospitalName: name,
                    location: location,
                    emergencyContacts: contacts
                )
            }
            onSave(saved)
            dismiss()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}

#Preview {
    HospitalFormSheet { _ in }
}

import SwiftUI

private enum HospitalSheetMode: Identifiable {
    case add
    case edit(Hospital)

    var id: String {
        switch self {
        case .add: return "add"
        case .edit(let hospital): return hospital.id
        }
    }

    var hospital: Hospital? {
        if case .edit(let hospital) = self { return hospital }
        return nil
    }
}

struct HospitalsListView: View {
    @State private var viewModel = HospitalsViewModel()
    @State private var sheetMode: HospitalSheetMode?

    var body: some View {
        List {
            if let errorMessage = viewModel.errorMessage, viewModel.hospitals.isEmpty {
                ContentUnavailableView {
                    Label("Couldn't load hospitals", systemImage: "exclamationmark.triangle")
                } description: {
                    Text(errorMessage)
                } actions: {
                    Button("Try again") { Task { await viewModel.load() } }
                }
            } else if viewModel.hospitals.isEmpty {
                ContentUnavailableView {
                    Label("No hospitals yet", systemImage: "cross.case")
                } description: {
                    Text("Add a hospital to book appointments and keep its details handy.")
                } actions: {
                    Button("Add hospital") {
                        sheetMode = .add
                    }
                }
            } else {
                ForEach(viewModel.hospitals) { hospital in
                    Button {
                        sheetMode = .edit(hospital)
                    } label: {
                        HStack(spacing: 12) {
                            hospitalIcon(hospital)
                            VStack(alignment: .leading, spacing: 4) {
                                Text(hospital.hospitalName)
                                    .font(.headline)
                                    .foregroundStyle(SSColor.textPrimary)
                                Text(hospital.location)
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                                if let phone = hospital.emergencyContacts.first {
                                    Text("Sickle Cell Unit: \(phone)")
                                        .font(.caption)
                                        .foregroundStyle(SSColor.textSecondary)
                                }
                            }
                        }
                    }
                    .buttonStyle(.plain)
                    .swipeActions {
                        Button("Delete", systemImage: "trash", role: .destructive) {
                            Task { await viewModel.delete(hospital) }
                        }
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle("Hospitals")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    sheetMode = .add
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .task { await viewModel.load() }
        .refreshable { await viewModel.load() }
        .sheet(item: $sheetMode) { mode in
            HospitalFormSheet(existingHospital: mode.hospital) { saved in
                viewModel.upsert(saved)
            }
        }
    }

    private func hospitalIcon(_ hospital: Hospital) -> some View {
        Image(systemName: "cross.case.fill")
            .foregroundStyle(SSColor.brand)
            .frame(width: 44, height: 44)
            .background(SSColor.surfaceSecondary)
            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
    }
}

#Preview {
    NavigationStack {
        HospitalsListView()
    }
}

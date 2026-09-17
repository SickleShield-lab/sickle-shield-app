import SwiftUI

struct HospitalsListView: View {
    @State private var viewModel = HospitalsViewModel()
    @State private var showAddSheet = false

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
                    Button("Add hospital") { showAddSheet = true }
                }
            } else {
                ForEach(viewModel.hospitals) { hospital in
                    VStack(alignment: .leading, spacing: 4) {
                        Text(hospital.hospitalName)
                            .font(.headline)
                        Text(hospital.location)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
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
                    showAddSheet = true
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .task { await viewModel.load() }
        .refreshable { await viewModel.load() }
        .sheet(isPresented: $showAddSheet) {
            AddHospitalSheet { name, location in
                await viewModel.addHospital(name: name, location: location)
            }
        }
    }
}

#Preview {
    NavigationStack {
        HospitalsListView()
    }
}

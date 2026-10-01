import SwiftUI

struct AppointmentsListView: View {
    @State private var viewModel = AppointmentsViewModel()
    @State private var showAddSheet = false

    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, yyyy"
        return formatter
    }()

    var body: some View {
        List {
            if let errorMessage = viewModel.errorMessage, viewModel.appointments.isEmpty {
                ContentUnavailableView {
                    Label("Couldn't load appointments", systemImage: "exclamationmark.triangle")
                } description: {
                    Text(errorMessage)
                } actions: {
                    Button("Try again") { Task { await viewModel.load() } }
                }
            } else if viewModel.appointments.isEmpty {
                ContentUnavailableView {
                    Label("No appointments yet", systemImage: "calendar")
                } description: {
                    Text("Book an appointment at one of your hospitals.")
                } actions: {
                    Button("Add appointment") { showAddSheet = true }
                        .disabled(viewModel.hospitals.isEmpty)
                }
            } else {
                ForEach(viewModel.appointments) { appointment in
                    HStack(alignment: .top) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(viewModel.hospitalName(for: appointment))
                                .font(.headline)
                            if let type = appointment.type, !type.isEmpty {
                                Text(type)
                                    .font(.subheadline)
                                    .foregroundStyle(SSColor.brand)
                            }
                            Text("\(Self.dateFormatter.string(from: appointment.date)) · \(appointment.shift) · \(appointment.time)")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                            if let doctorName = appointment.doctorName, !doctorName.isEmpty {
                                Text(doctorName)
                                    .font(.footnote)
                                    .foregroundStyle(.secondary)
                            }
                            Text(appointment.status.capitalized)
                                .font(.caption)
                                .foregroundStyle(SSColor.brand)
                        }
                        Spacer()
                        Text(appointment.countdownText)
                            .font(.system(.caption, weight: .semibold))
                            .foregroundStyle(SSColor.brand)
                    }
                    .swipeActions {
                        Button("Delete", systemImage: "trash", role: .destructive) {
                            Task { await viewModel.delete(appointment) }
                        }
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle("Appointments")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    showAddSheet = true
                } label: {
                    Image(systemName: "plus")
                }
                .disabled(viewModel.hospitals.isEmpty)
            }
        }
        .task { await viewModel.load() }
        .refreshable { await viewModel.load() }
        .sheet(isPresented: $showAddSheet) {
            AddAppointmentSheet(hospitals: viewModel.hospitals) { hospitalId, doctorName, type, date, shift, time, remindThreeDaysBefore, remindTwoDaysBefore in
                await viewModel.addAppointment(
                    hospitalId: hospitalId, doctorName: doctorName, type: type, date: date, shift: shift, time: time,
                    remindThreeDaysBefore: remindThreeDaysBefore, remindTwoDaysBefore: remindTwoDaysBefore
                )
            }
        }
    }
}

#Preview {
    NavigationStack {
        AppointmentsListView()
    }
}

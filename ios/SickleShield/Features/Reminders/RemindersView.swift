import SwiftUI

struct RemindersView: View {
    @StateObject private var viewModel = RemindersViewModel()
    @State private var showAddSheet = false
    @State private var editingReminder: Reminder?

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                GlassHeader {
                    Text("Reminders")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundStyle(.white)
                }
                .frame(height: 90)

                if let errorMessage = viewModel.errorMessage, viewModel.reminders.isEmpty {
                    ErrorState(message: errorMessage) {
                        Task { await viewModel.load() }
                    }
                    .padding(.top, 40)
                } else {
                    VStack(spacing: 14) {
                        if viewModel.reminders.isEmpty {
                            Text(viewModel.isLoading ? "Loading..." : "No reminders yet")
                                .font(.system(size: 12))
                                .foregroundStyle(SSColor.textSecondary)
                                .padding(.top, 20)
                        } else {
                            VStack(spacing: 10) {
                                ForEach(viewModel.reminders) { reminder in
                                    HStack {
                                        VStack(alignment: .leading, spacing: 2) {
                                            Text(reminder.medicineName)
                                                .font(.system(size: 13, weight: .medium))
                                                .foregroundStyle(SSColor.textPrimary)
                                            Text("\(reminder.medicineType) · \(reminder.amount)")
                                                .font(.system(size: 10))
                                                .foregroundStyle(SSColor.textSecondary)
                                        }
                                        Spacer()
                                        Button {
                                            editingReminder = reminder
                                        } label: {
                                            Text(reminder.reminderTime)
                                                .font(.system(size: 10, weight: .medium))
                                                .foregroundStyle(SSColor.textPrimary)
                                                .padding(.horizontal, 9)
                                                .padding(.vertical, 4)
                                                .neumorphicPressed(radius: 9)
                                        }
                                        .buttonStyle(.plain)
                                        Button {
                                            Task { await viewModel.delete(reminder) }
                                        } label: {
                                            Image(systemName: "trash")
                                                .font(.system(size: 13))
                                                .foregroundStyle(SSColor.textSecondary)
                                        }
                                        .buttonStyle(.plain)
                                        .padding(.leading, 4)
                                    }
                                    .padding(14)
                                    .neumorphicCard()
                                }
                            }
                        }

                        Button {
                            showAddSheet = true
                        } label: {
                            Text("Add medicine")
                                .font(.system(size: 13, weight: .medium))
                                .foregroundStyle(SSColor.brand)
                                .frame(maxWidth: .infinity)
                                .padding(13)
                        }
                        .neumorphicPressed()
                    }
                    .padding(16)
                }
            }
        }
        .background(SSColor.background.ignoresSafeArea())
        .task {
            await viewModel.load()
        }
        .refreshable {
            await viewModel.load()
        }
        .sheet(isPresented: $showAddSheet) {
            AddReminderSheet(viewModel: viewModel)
        }
        .sheet(item: $editingReminder) { reminder in
            EditReminderTimeSheet(viewModel: viewModel, reminder: reminder)
        }
    }
}

private struct EditReminderTimeSheet: View {
    @ObservedObject var viewModel: RemindersViewModel
    let reminder: Reminder
    @Environment(\.dismiss) private var dismiss
    @State private var time: Date
    @State private var isSaving = false

    private static let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter
    }()

    init(viewModel: RemindersViewModel, reminder: Reminder) {
        self.viewModel = viewModel
        self.reminder = reminder
        let parsed = ["h:mm a", "HH:mm"].lazy.compactMap { format -> Date? in
            let formatter = DateFormatter()
            formatter.dateFormat = format
            return formatter.date(from: reminder.reminderTime)
        }.first
        _time = State(initialValue: parsed ?? Date())
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Text(reminder.medicineName)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(SSColor.textPrimary)
                DatePicker("Time", selection: $time, displayedComponents: .hourAndMinute)
                    .labelsHidden()
                    .datePickerStyle(.wheel)
                Spacer()
            }
            .padding(20)
            .background(SSColor.background.ignoresSafeArea())
            .navigationTitle("Edit time")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button {
                        Task {
                            isSaving = true
                            let saved = await viewModel.updateReminderTime(reminder, time: Self.timeFormatter.string(from: time))
                            isSaving = false
                            if saved { dismiss() }
                        }
                    } label: {
                        if isSaving {
                            ProgressView()
                        } else {
                            Text("Save")
                        }
                    }
                    .disabled(isSaving)
                }
            }
        }
    }
}

#Preview {
    RemindersView()
}

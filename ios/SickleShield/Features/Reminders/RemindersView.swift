import SwiftUI

struct RemindersView: View {
    @StateObject private var viewModel = RemindersViewModel()
    @State private var showAddSheet = false

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
                                        Text(reminder.reminderTime)
                                            .font(.system(size: 10, weight: .medium))
                                            .foregroundStyle(SSColor.textPrimary)
                                            .padding(.horizontal, 9)
                                            .padding(.vertical, 4)
                                            .neumorphicPressed(radius: 9)
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
    }
}

#Preview {
    RemindersView()
}

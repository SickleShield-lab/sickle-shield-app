import SwiftUI
import UIKit

struct EmergencyView: View {
    @StateObject private var viewModel = EmergencyViewModel()
    @State private var showAddSheet = false
    @State private var showCrisisMode = false
    @State private var showContactPicker = false
    @State private var selectedContactIDs: Set<String> = []

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                GlassHeader {
                    Text("Emergency")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundStyle(.white)
                }
                .frame(height: 90)

                VStack(spacing: 16) {
                    PulsingSOSButton {
                        guard !viewModel.contacts.isEmpty else {
                            viewModel.sosStatus = "Add an emergency contact first."
                            return
                        }
                        selectedContactIDs = Set(viewModel.contacts.map(\.id))
                        showContactPicker = true
                    }
                    .padding(.top, 8)
                    .opacity(viewModel.isSendingSOS ? 0.6 : 1)
                    .disabled(viewModel.isSendingSOS)

                    Text(viewModel.sosStatus)
                        .font(.system(size: 11))
                        .foregroundStyle(SSColor.textSecondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)

                    Button {
                        showCrisisMode = true
                    } label: {
                        Text(viewModel.isCrisisActive ? "Resume Crisis Mode" : "Start Crisis Mode")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding(13)
                            .background(SSColor.brand)
                            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                    }

                    if viewModel.isCrisisActive {
                        Button {
                            viewModel.endCrisis()
                        } label: {
                            Text("Mark crisis as resolved")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundStyle(SSColor.brand)
                        }
                        .buttonStyle(.plain)
                    }

                    if let errorMessage = viewModel.errorMessage, viewModel.contacts.isEmpty {
                        ErrorState(message: errorMessage) {
                            Task { await viewModel.load() }
                        }
                    } else if viewModel.contacts.isEmpty {
                        Text(viewModel.isLoading ? "Loading..." : "No emergency contacts yet")
                            .font(.system(size: 12))
                            .foregroundStyle(SSColor.textSecondary)
                    } else {
                        VStack(spacing: 10) {
                            ForEach(viewModel.contacts) { contact in
                                HStack {
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(contact.contactName)
                                            .font(.system(size: 13, weight: .medium))
                                            .foregroundStyle(SSColor.textPrimary)
                                        Text(contact.contactNumber)
                                            .font(.system(size: 10))
                                            .foregroundStyle(SSColor.textSecondary)
                                    }
                                    Spacer()
                                    Button {
                                        callContact(contact)
                                    } label: {
                                        Image(systemName: "phone.fill")
                                            .font(.system(size: 16))
                                            .foregroundStyle(SSColor.brand)
                                    }
                                    .buttonStyle(.plain)
                                    Button {
                                        Task { await viewModel.delete(contact) }
                                    } label: {
                                        Image(systemName: "trash")
                                            .font(.system(size: 13))
                                            .foregroundStyle(SSColor.textSecondary)
                                    }
                                    .buttonStyle(.plain)
                                    .padding(.leading, 6)
                                }
                                .padding(14)
                                .neumorphicCard()
                            }
                        }
                    }

                    Button {
                        showAddSheet = true
                    } label: {
                        Text("Setup emergency contact")
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
        .background(SSColor.background.ignoresSafeArea())
        .task {
            await viewModel.load()
        }
        .refreshable {
            await viewModel.load()
        }
        .onChange(of: viewModel.pendingSOSURL) { _, url in
            guard let url else { return }
            UIApplication.shared.open(url)
            viewModel.pendingSOSURL = nil
        }
        .sheet(isPresented: $showAddSheet) {
            AddEmergencyContactSheet { name, number in
                do {
                    try await HospitalAPI.createEmergencyContact(name: name, number: number)
                    await viewModel.load()
                    return true
                } catch {
                    return false
                }
            }
        }
        .fullScreenCover(isPresented: $showCrisisMode) {
            CrisisModeView(viewModel: viewModel)
        }
        .sheet(isPresented: $showContactPicker) {
            SOSContactPickerSheet(contacts: viewModel.contacts, selectedIDs: $selectedContactIDs) { selected in
                Task { await viewModel.triggerSOS(to: selected) }
            }
        }
    }

    private func callContact(_ contact: EmergencyContact) {
        let sanitized = contact.contactNumber.filter { $0.isNumber || $0 == "+" }
        guard let url = URL(string: "tel://\(sanitized)") else { return }
        UIApplication.shared.open(url)
    }
}

private struct SOSContactPickerSheet: View {
    let contacts: [EmergencyContact]
    @Binding var selectedIDs: Set<String>
    let onSend: ([EmergencyContact]) -> Void
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            List(contacts) { contact in
                Button {
                    if selectedIDs.contains(contact.id) {
                        selectedIDs.remove(contact.id)
                    } else {
                        selectedIDs.insert(contact.id)
                    }
                } label: {
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(contact.contactName)
                                .foregroundStyle(SSColor.textPrimary)
                            Text(contact.contactNumber)
                                .font(.caption)
                                .foregroundStyle(SSColor.textSecondary)
                        }
                        Spacer()
                        Image(systemName: selectedIDs.contains(contact.id) ? "checkmark.circle.fill" : "circle")
                            .foregroundStyle(selectedIDs.contains(contact.id) ? SSColor.brand : SSColor.textSecondary)
                    }
                }
                .buttonStyle(.plain)
            }
            .navigationTitle("Notify Who?")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Send SOS") {
                        let selected = contacts.filter { selectedIDs.contains($0.id) }
                        dismiss()
                        onSend(selected)
                    }
                    .disabled(selectedIDs.isEmpty)
                    .foregroundStyle(SSColor.brand)
                }
            }
        }
    }
}

#Preview {
    EmergencyView()
}

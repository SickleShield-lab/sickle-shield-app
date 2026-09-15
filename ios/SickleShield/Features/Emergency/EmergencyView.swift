import SwiftUI
import UIKit

struct EmergencyView: View {
    @StateObject private var viewModel = EmergencyViewModel()
    @State private var showAddSheet = false

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
                        Task { await viewModel.triggerSOS() }
                    }
                    .padding(.top, 8)
                    .opacity(viewModel.isSendingSOS ? 0.6 : 1)
                    .disabled(viewModel.isSendingSOS)

                    Text(viewModel.sosStatus)
                        .font(.system(size: 11))
                        .foregroundStyle(Theme.muted)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)

                    if viewModel.isCrisisActive {
                        Button {
                            viewModel.endCrisis()
                        } label: {
                            Text("Mark crisis as resolved")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundStyle(Theme.deepRed)
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
                            .foregroundStyle(Theme.muted)
                    } else {
                        VStack(spacing: 10) {
                            ForEach(viewModel.contacts) { contact in
                                HStack {
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(contact.contactName)
                                            .font(.system(size: 13, weight: .medium))
                                            .foregroundStyle(Theme.ink)
                                        Text(contact.contactNumber)
                                            .font(.system(size: 10))
                                            .foregroundStyle(Theme.muted)
                                    }
                                    Spacer()
                                    Button {
                                        callContact(contact)
                                    } label: {
                                        Image(systemName: "phone.fill")
                                            .font(.system(size: 16))
                                            .foregroundStyle(Theme.deepRed)
                                    }
                                    .buttonStyle(.plain)
                                    Button {
                                        Task { await viewModel.delete(contact) }
                                    } label: {
                                        Image(systemName: "trash")
                                            .font(.system(size: 13))
                                            .foregroundStyle(Theme.muted)
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
                            .foregroundStyle(Theme.accent)
                            .frame(maxWidth: .infinity)
                            .padding(13)
                    }
                    .neumorphicPressed()
                }
                .padding(16)
            }
        }
        .background(Theme.background.ignoresSafeArea())
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
    }

    private func callContact(_ contact: EmergencyContact) {
        let sanitized = contact.contactNumber.filter { $0.isNumber || $0 == "+" }
        guard let url = URL(string: "tel://\(sanitized)") else { return }
        UIApplication.shared.open(url)
    }
}

#Preview {
    EmergencyView()
}

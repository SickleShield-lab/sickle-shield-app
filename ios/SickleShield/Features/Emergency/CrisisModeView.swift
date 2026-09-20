import SwiftUI
import UIKit

/// Full-bleed, high-contrast crisis companion screen. User-initiated only -
/// nothing here ever presents itself automatically. Backed by the shared
/// `EmergencyViewModel` so it sees the same contacts/crisis state as the
/// Emergency tab.
struct CrisisModeView: View {
    @ObservedObject var viewModel: EmergencyViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var pendingSeverity: Double = 5
    @State private var isStarting = false
    @State private var showPainPlan = false
    @State private var showMedicalID = false
    @State private var showEndConfirmation = false
    @State private var showEmergencyCallConfirmation = false

    @AppStorage("caregiverName") private var caregiverName = ""
    @AppStorage("caregiverPhone") private var caregiverPhone = ""
    @AppStorage("specialistName") private var specialistName = ""
    @AppStorage("specialistPhone") private var specialistPhone = ""

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            if viewModel.crisisStartedAt != nil {
                activeContent
            } else {
                startContent
            }
        }
        .sheet(isPresented: $showPainPlan) {
            NavigationStack { PersonalPainPlanView() }
        }
        .sheet(isPresented: $showMedicalID) {
            NavigationStack { MedicalIDView() }
        }
    }

    // MARK: - Before a crisis is started

    private var startContent: some View {
        VStack(spacing: SSSpacing.xl) {
            Spacer()
            Text("Start Crisis Mode")
                .font(.system(.title, weight: .bold))
                .foregroundStyle(.white)
            Text("How bad is your pain right now?")
                .foregroundStyle(.white.opacity(0.7))

            Text("\(Int(pendingSeverity))")
                .font(.system(size: 72, weight: .bold))
                .foregroundStyle(SSColor.brand)
                .contentTransition(.numericText())
                .animation(.spring(response: 0.3, dampingFraction: 1), value: pendingSeverity)

            Slider(value: $pendingSeverity, in: 0...10, step: 1)
                .tint(SSColor.brand)
                .padding(.horizontal, SSSpacing.xxl)

            if pendingSeverity < 7 {
                Text("Crisis Mode is for severe pain (7-10). For pain below that, contact NHS 111 for advice.")
                    .font(.footnote)
                    .foregroundStyle(.white.opacity(0.7))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, SSSpacing.xxl)

                Button {
                    callNumber("111")
                } label: {
                    Text("Call NHS 111")
                }
                .buttonStyle(.ssPrimary)
                .padding(.horizontal, SSSpacing.xxl)
            } else {
                Button {
                    Task {
                        isStarting = true
                        _ = await viewModel.startCrisisMode(severity: Int(pendingSeverity))
                        isStarting = false
                    }
                } label: {
                    if isStarting {
                        ProgressView().tint(.white)
                    } else {
                        Text("Start Crisis Mode")
                    }
                }
                .buttonStyle(.ssPrimary)
                .padding(.horizontal, SSSpacing.xxl)
                .disabled(isStarting)
            }

            Button("Cancel") { dismiss() }
                .foregroundStyle(.white.opacity(0.7))
                .padding(.top, SSSpacing.sm)

            Spacer()
        }
        .padding()
    }

    // MARK: - Active crisis

    private var activeContent: some View {
        ScrollView {
            VStack(spacing: SSSpacing.xl) {
                HStack {
                    Spacer()
                    Button {
                        showEndConfirmation = true
                    } label: {
                        Text("End Crisis")
                            .font(.system(.subheadline, weight: .semibold))
                            .foregroundStyle(.white.opacity(0.7))
                    }
                }
                .padding(.horizontal)

                VStack(spacing: 4) {
                    Text("\(viewModel.crisisSeverity ?? 0)")
                        .font(.system(size: 96, weight: .bold))
                        .foregroundStyle(SSColor.brand)
                    Text("out of 10")
                        .foregroundStyle(.white.opacity(0.7))
                }

                if let startedAt = viewModel.crisisStartedAt {
                    VStack(spacing: 2) {
                        Text(startedAt, style: .timer)
                            .font(.system(.title2, design: .monospaced, weight: .semibold))
                            .foregroundStyle(.white)
                        Text("Since crisis started")
                            .font(.caption)
                            .foregroundStyle(.white.opacity(0.6))
                    }
                }

                VStack(spacing: SSSpacing.sm) {
                    crisisRow(icon: "heart.text.square.fill", title: "My Pain Plan") { showPainPlan = true }
                    crisisRow(icon: "cross.case.fill", title: "Medical ID") { showMedicalID = true }
                    if !caregiverPhone.isEmpty {
                        crisisCallRow(title: caregiverName.isEmpty ? "Caregiver" : caregiverName, phone: caregiverPhone)
                    }
                    if !specialistPhone.isEmpty {
                        crisisCallRow(title: specialistName.isEmpty ? "Specialist" : specialistName, phone: specialistPhone, highlighted: true)
                    }
                }
                .padding(.horizontal)

                if !viewModel.contacts.isEmpty {
                    VStack(alignment: .leading, spacing: SSSpacing.sm) {
                        Text("Contacts")
                            .font(.system(.caption, weight: .bold))
                            .foregroundStyle(.white.opacity(0.6))
                            .textCase(.uppercase)
                        ForEach(viewModel.contacts) { contact in
                            Button {
                                callNumber(contact.contactNumber)
                            } label: {
                                HStack {
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(contact.contactName)
                                            .foregroundStyle(.white)
                                        Text(contact.contactNumber)
                                            .font(.caption)
                                            .foregroundStyle(.white.opacity(0.6))
                                    }
                                    Spacer()
                                    Image(systemName: "phone.fill")
                                        .foregroundStyle(SSColor.brand)
                                }
                                .padding()
                                .background(Color.white.opacity(0.08))
                                .clipShape(RoundedRectangle(cornerRadius: SSRadius.md, style: .continuous))
                            }
                        }
                    }
                    .padding(.horizontal)
                }

                Button {
                    showEmergencyCallConfirmation = true
                } label: {
                    Text("Call Emergency Services")
                        .font(.system(.headline, weight: .bold))
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(SSColor.brand)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: SSRadius.md, style: .continuous))
                }
                .padding(.horizontal)
                .padding(.bottom, SSSpacing.xxl)
            }
            .padding(.top, SSSpacing.xl)
        }
        .confirmationDialog("End this crisis?", isPresented: $showEndConfirmation, titleVisibility: .visible) {
            Button("End Crisis", role: .destructive) {
                viewModel.endCrisis()
                dismiss()
            }
        }
        .confirmationDialog("Call emergency services now?", isPresented: $showEmergencyCallConfirmation, titleVisibility: .visible) {
            Button("Call", role: .destructive) { callNumber("999") }
        }
    }

    private func crisisRow(icon: String, title: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon)
                    .foregroundStyle(SSColor.brand)
                Text(title)
                    .foregroundStyle(.white)
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundStyle(.white.opacity(0.4))
            }
            .padding()
            .background(Color.white.opacity(0.08))
            .clipShape(RoundedRectangle(cornerRadius: SSRadius.md, style: .continuous))
        }
    }

    private func crisisCallRow(title: String, phone: String, highlighted: Bool = false) -> some View {
        Button {
            callNumber(phone)
        } label: {
            HStack {
                Text("\(title) — Call")
                    .font(.system(.body, weight: .semibold))
                    .foregroundStyle(.white)
                Spacer()
                Image(systemName: "phone.fill")
                    .foregroundStyle(.white.opacity(highlighted ? 1 : 0.7))
            }
            .padding()
            .background(highlighted ? SSColor.brand : Color.white.opacity(0.08))
            .clipShape(RoundedRectangle(cornerRadius: SSRadius.md, style: .continuous))
        }
    }

    private func callNumber(_ raw: String) {
        let sanitized = raw.filter { $0.isNumber || $0 == "+" }
        guard let url = URL(string: "tel://\(sanitized)") else { return }
        UIApplication.shared.open(url)
    }
}

#Preview {
    CrisisModeView(viewModel: EmergencyViewModel())
}

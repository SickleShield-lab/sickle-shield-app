import SwiftUI

struct SetUpProfileView: View {
    @EnvironmentObject private var session: SessionStore
    let onFinish: () -> Void

    @State private var gender = ""
    @State private var weight = ""
    @State private var bloodGroup = ""
    @State private var isSaving = false
    @State private var errorMessage: String?

    private static let genders = ["", "Male", "Female", "Other"]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    VStack(spacing: 6) {
                        Text("Set up your profile")
                            .font(.system(size: 20, weight: .medium))
                            .foregroundStyle(SSColor.textPrimary)
                        Text("A few details help us tailor your crisis risk score and care tips.")
                            .font(.system(size: 12))
                            .foregroundStyle(SSColor.textSecondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, 40)

                    VStack(spacing: 14) {
                        LabeledField(label: "Gender") {
                            Picker("Gender", selection: $gender) {
                                ForEach(Self.genders, id: \.self) { option in
                                    Text(option.isEmpty ? "Prefer not to say" : option).tag(option)
                                }
                            }
                            .pickerStyle(.menu)
                        }
                        LabeledField(label: "Weight (kg)") {
                            TextField("e.g. 70", text: $weight)
                                .keyboardType(.decimalPad)
                        }
                        LabeledField(label: "Blood group") {
                            TextField("e.g. AA, AS, SS", text: $bloodGroup)
                        }

                        if let errorMessage {
                            Text(errorMessage)
                                .font(.system(size: 12))
                                .foregroundStyle(SSColor.brand)
                        }

                        Button {
                            Task { await save() }
                        } label: {
                            HStack {
                                if isSaving {
                                    ProgressView().tint(SSColor.brand)
                                } else {
                                    Text("Continue")
                                }
                            }
                            .font(.system(size: 14, weight: .medium))
                            .foregroundStyle(SSColor.brand)
                            .frame(maxWidth: .infinity)
                            .padding(13)
                        }
                        .neumorphicPressed()
                        .disabled(isSaving)

                        Button("Skip for now", action: onFinish)
                            .font(.system(size: 12))
                            .foregroundStyle(SSColor.textSecondary)
                    }
                    .padding(20)
                    .neumorphicCard()
                }
                .padding(20)
            }
            .background(SSColor.background.ignoresSafeArea())
        }
    }

    private func save() async {
        isSaving = true
        errorMessage = nil
        defer { isSaving = false }
        let payload = AuthAPI.UpdateProfileRequest(
            gender: gender.isEmpty ? nil : gender,
            weight: weight.isEmpty ? nil : weight,
            bloodGroup: bloodGroup.isEmpty ? nil : bloodGroup
        )
        do {
            session.currentUser = try await AuthAPI.updateProfile(payload)
            onFinish()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}

#Preview {
    SetUpProfileView(onFinish: {})
        .environmentObject(SessionStore())
}

import SwiftUI

struct EditProfileView: View {
    @EnvironmentObject private var session: SessionStore
    @Environment(\.dismiss) private var dismiss

    @State private var username = ""
    @State private var mobileNumber = ""
    @State private var gender = ""
    @State private var smoking = false
    @State private var diagnosis = ""
    @State private var weight = ""
    @State private var bloodGroup = ""
    @State private var waterIntake = 10
    @State private var isSaving = false
    @State private var errorMessage: String?

    private static let genders = ["", "Male", "Female", "Other"]

    var body: some View {
        Form {
            Section("Personal") {
                TextField("Name", text: $username)
                    .textContentType(.name)
                Picker("Gender", selection: $gender) {
                    ForEach(Self.genders, id: \.self) { option in
                        Text(option.isEmpty ? "Not set" : option).tag(option)
                    }
                }
                TextField("Mobile number", text: $mobileNumber)
                    .keyboardType(.phonePad)
            }

            Section("Health") {
                TextField("Weight (kg)", text: $weight)
                    .keyboardType(.decimalPad)
                TextField("Blood group, e.g. AA, AS, SS", text: $bloodGroup)
                Toggle("Smoker", isOn: $smoking)
                Stepper("Water goal: \(waterIntake) glasses/day", value: $waterIntake, in: 1...10)
                TextField("Diagnosis notes", text: $diagnosis, axis: .vertical)
            }

            if let errorMessage {
                Text(errorMessage)
                    .foregroundStyle(.red)
            }
        }
        .navigationTitle("Edit profile")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
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
                .disabled(isSaving)
            }
        }
        .onAppear(perform: prefill)
    }

    private func prefill() {
        guard let user = session.currentUser else { return }
        username = user.username
        mobileNumber = user.mobileNumber ?? ""
        gender = user.gender ?? ""
        smoking = user.smoking ?? false
        diagnosis = user.diagnosis ?? ""
        weight = user.weight ?? ""
        bloodGroup = user.bloodGroup ?? ""
        waterIntake = user.waterIntake ?? 10
    }

    private func save() async {
        isSaving = true
        errorMessage = nil
        defer { isSaving = false }
        let payload = AuthAPI.UpdateProfileRequest(
            username: username.isEmpty ? nil : username,
            mobileNumber: mobileNumber.isEmpty ? nil : mobileNumber,
            gender: gender.isEmpty ? nil : gender,
            smoking: smoking,
            diagnosis: diagnosis.isEmpty ? nil : diagnosis,
            weight: weight.isEmpty ? nil : weight,
            bloodGroup: bloodGroup.isEmpty ? nil : bloodGroup,
            waterIntake: waterIntake
        )
        do {
            session.currentUser = try await AuthAPI.updateProfile(payload)
            dismiss()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}

#Preview {
    NavigationStack {
        EditProfileView()
            .environmentObject(SessionStore())
    }
}

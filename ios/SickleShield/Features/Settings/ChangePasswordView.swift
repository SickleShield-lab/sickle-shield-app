import SwiftUI

struct ChangePasswordView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var newPassword = ""
    @State private var confirmPassword = ""
    @State private var isSaving = false
    @State private var errorMessage: String?
    @State private var didSucceed = false

    private var canSave: Bool {
        newPassword.count >= 8 && newPassword == confirmPassword
    }

    var body: some View {
        Form {
            Section {
                SecureField("New password", text: $newPassword)
                    .textContentType(.newPassword)
                SecureField("Confirm new password", text: $confirmPassword)
                    .textContentType(.newPassword)
            } footer: {
                Text("At least 8 characters, with an uppercase letter, a lowercase letter, a number, and a special character.")
            }

            if let errorMessage {
                Text(errorMessage)
                    .foregroundStyle(.red)
            }
            if didSucceed {
                Text("Password updated.")
                    .foregroundStyle(SSColor.success)
            }
        }
        .navigationTitle("Change Password")
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
                .disabled(isSaving || !canSave)
            }
        }
    }

    private func save() async {
        isSaving = true
        errorMessage = nil
        defer { isSaving = false }
        do {
            _ = try await AuthAPI.updateProfile(AuthAPI.UpdateProfileRequest(password: newPassword))
            didSucceed = true
            newPassword = ""
            confirmPassword = ""
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}

#Preview {
    NavigationStack {
        ChangePasswordView()
    }
}

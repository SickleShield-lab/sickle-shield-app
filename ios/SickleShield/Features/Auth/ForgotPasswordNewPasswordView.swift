import SwiftUI

struct ForgotPasswordNewPasswordView: View {
    let tempToken: String
    @Binding var dismissAll: Bool

    @State private var newPassword = ""
    @State private var confirmPassword = ""
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var showSuccess = false

    private var passwordsMismatch: Bool {
        !confirmPassword.isEmpty && newPassword != confirmPassword
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Text("Set a new password")
                    .font(.system(size: 20, weight: .medium))
                    .foregroundStyle(SSColor.textPrimary)
                    .padding(.top, 40)

                VStack(spacing: 14) {
                    LabeledField(label: "New password") {
                        SecureField("At least 8 characters", text: $newPassword)
                    }
                    LabeledField(label: "Confirm password") {
                        SecureField("Re-enter password", text: $confirmPassword)
                    }

                    if passwordsMismatch {
                        Text("Passwords don't match.")
                            .font(.system(size: 12))
                            .foregroundStyle(SSColor.brand)
                    }
                    if let errorMessage {
                        Text(errorMessage)
                            .font(.system(size: 12))
                            .foregroundStyle(SSColor.brand)
                    }

                    Button {
                        Task { await reset() }
                    } label: {
                        HStack {
                            if isLoading {
                                ProgressView().tint(SSColor.brand)
                            } else {
                                Text("Reset password")
                            }
                        }
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(SSColor.brand)
                        .frame(maxWidth: .infinity)
                        .padding(13)
                    }
                    .neumorphicPressed()
                    .disabled(isLoading || newPassword.count < 8 || passwordsMismatch)
                }
                .padding(20)
                .neumorphicCard()
            }
            .padding(20)
        }
        .background(SSColor.background.ignoresSafeArea())
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(isPresented: $showSuccess) {
            ForgotPasswordSuccessView(dismissAll: $dismissAll)
        }
    }

    private func reset() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        do {
            try await AuthAPI.resetPassword(newPassword: newPassword, tempToken: tempToken)
            showSuccess = true
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}

#Preview {
    NavigationStack {
        ForgotPasswordNewPasswordView(tempToken: "preview", dismissAll: .constant(true))
    }
}

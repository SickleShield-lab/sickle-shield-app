import SwiftUI

struct ForgotPasswordEmailView: View {
    @Binding var dismissAll: Bool

    @State private var email = ""
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var showOTP = false

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                VStack(spacing: 6) {
                    Text("Reset password")
                        .font(.system(size: 20, weight: .medium))
                        .foregroundStyle(SSColor.textPrimary)
                    Text("Enter your account email and we'll send you a code")
                        .font(.system(size: 12))
                        .foregroundStyle(SSColor.textSecondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 40)

                VStack(spacing: 14) {
                    LabeledField(label: "Email") {
                        TextField("you@example.com", text: $email)
                            .textInputAutocapitalization(.never)
                            .keyboardType(.emailAddress)
                            .autocorrectionDisabled()
                    }

                    if let errorMessage {
                        Text(errorMessage)
                            .font(.system(size: 12))
                            .foregroundStyle(SSColor.brand)
                    }

                    Button {
                        Task { await sendCode() }
                    } label: {
                        HStack {
                            if isLoading {
                                ProgressView().tint(SSColor.brand)
                            } else {
                                Text("Send code")
                            }
                        }
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(SSColor.brand)
                        .frame(maxWidth: .infinity)
                        .padding(13)
                    }
                    .neumorphicPressed()
                    .disabled(isLoading || email.isEmpty)
                }
                .padding(20)
                .neumorphicCard()
            }
            .padding(20)
        }
        .background(SSColor.background.ignoresSafeArea())
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(isPresented: $showOTP) {
            ForgotPasswordOTPView(email: email, dismissAll: $dismissAll)
        }
    }

    private func sendCode() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        do {
            try await AuthAPI.sendForgotPasswordOtp(email: email)
            showOTP = true
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}

#Preview {
    NavigationStack {
        ForgotPasswordEmailView(dismissAll: .constant(true))
    }
}

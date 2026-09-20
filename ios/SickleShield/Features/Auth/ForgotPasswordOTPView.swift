import SwiftUI

struct ForgotPasswordOTPView: View {
    let email: String
    @Binding var dismissAll: Bool

    @State private var otp = ""
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var tempToken: String?

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                VStack(spacing: 6) {
                    Text("Enter the code")
                        .font(.system(size: 20, weight: .medium))
                        .foregroundStyle(SSColor.textPrimary)
                    Text("Enter the 4-digit code sent to \(email)")
                        .font(.system(size: 12))
                        .foregroundStyle(SSColor.textSecondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 40)

                VStack(spacing: 14) {
                    TextField("0000", text: $otp)
                        .keyboardType(.numberPad)
                        .multilineTextAlignment(.center)
                        .font(.system(size: 22, weight: .medium))
                        .foregroundStyle(SSColor.textPrimary)
                        .padding(12)
                        .neumorphicCard(radius: 12)

                    if let errorMessage {
                        Text(errorMessage)
                            .font(.system(size: 12))
                            .foregroundStyle(SSColor.brand)
                    }

                    Button {
                        Task { await verify() }
                    } label: {
                        HStack {
                            if isLoading {
                                ProgressView().tint(SSColor.brand)
                            } else {
                                Text("Verify")
                            }
                        }
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(SSColor.brand)
                        .frame(maxWidth: .infinity)
                        .padding(13)
                    }
                    .neumorphicPressed()
                    .disabled(isLoading || otp.count != 4)
                }
                .padding(20)
                .neumorphicCard()
            }
            .padding(20)
        }
        .background(SSColor.background.ignoresSafeArea())
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(isPresented: Binding(
            get: { tempToken != nil },
            set: { if !$0 { tempToken = nil } }
        )) {
            if let tempToken {
                ForgotPasswordNewPasswordView(tempToken: tempToken, dismissAll: $dismissAll)
            }
        }
    }

    private func verify() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        do {
            tempToken = try await AuthAPI.verifyForgotPasswordOtp(email: email, otp: otp)
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}

#Preview {
    NavigationStack {
        ForgotPasswordOTPView(email: "test@example.com", dismissAll: .constant(true))
    }
}

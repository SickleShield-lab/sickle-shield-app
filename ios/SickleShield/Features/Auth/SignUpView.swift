import SwiftUI

struct SignUpView: View {
    @Binding var showSignUp: Bool

    @State private var username = ""
    @State private var email = ""
    @State private var password = ""
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var showOTP = false

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Text("Create account")
                    .font(.system(size: 20, weight: .medium))
                    .foregroundStyle(SSColor.textPrimary)
                    .padding(.top, 40)

                VStack(spacing: 14) {
                    LabeledField(label: "Name") {
                        TextField("Full name", text: $username)
                    }
                    LabeledField(label: "Email") {
                        TextField("you@example.com", text: $email)
                            .textInputAutocapitalization(.never)
                            .keyboardType(.emailAddress)
                            .autocorrectionDisabled()
                    }
                    LabeledField(label: "Password") {
                        SecureField("At least 8 characters", text: $password)
                    }

                    if let errorMessage {
                        Text(errorMessage)
                            .font(.system(size: 12))
                            .foregroundStyle(SSColor.brand)
                    }

                    Button {
                        Task { await signUp() }
                    } label: {
                        HStack {
                            if isLoading {
                                ProgressView().tint(SSColor.brand)
                            } else {
                                Text("Sign up")
                            }
                        }
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(SSColor.brand)
                        .frame(maxWidth: .infinity)
                        .padding(13)
                    }
                    .neumorphicPressed()
                    .disabled(isLoading || username.isEmpty || email.isEmpty || password.count < 8)

                    Button {
                        showSignUp = false
                    } label: {
                        Text("Already have an account? Sign in")
                            .font(.system(size: 12))
                            .foregroundStyle(SSColor.brand)
                    }
                }
                .padding(20)
                .neumorphicCard()
            }
            .padding(20)
        }
        .background(SSColor.background.ignoresSafeArea())
        .navigationDestination(isPresented: $showOTP) {
            OTPVerificationView(email: email, showSignUp: $showSignUp)
        }
    }

    private func signUp() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        do {
            try await AuthAPI.signUp(username: username, email: email, password: password)
            showOTP = true
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}

#Preview {
    NavigationStack {
        SignUpView(showSignUp: .constant(true))
    }
}

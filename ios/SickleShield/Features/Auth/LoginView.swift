import SwiftUI

struct LoginView: View {
    @EnvironmentObject private var session: SessionStore
    @Binding var showSignUp: Bool

    @State private var email = ""
    @State private var password = ""
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var showForgotPassword = false

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                VStack(spacing: 6) {
                    Image(systemName: "shield.lefthalf.filled")
                        .font(.system(size: 40))
                        .foregroundStyle(SSColor.brand)
                    Text("Sickle Shield")
                        .font(.system(size: 20, weight: .medium))
                        .foregroundStyle(SSColor.textPrimary)
                    Text("Your health. Your control. Every day.")
                        .font(.system(size: 12))
                        .foregroundStyle(SSColor.textSecondary)
                }
                .padding(.top, 40)

                VStack(spacing: 14) {
                    LabeledField(label: "Email") {
                        TextField("you@example.com", text: $email)
                            .textInputAutocapitalization(.never)
                            .keyboardType(.emailAddress)
                            .autocorrectionDisabled()
                    }
                    LabeledField(label: "Password") {
                        SecureField("Enter your password", text: $password)
                    }

                    if let errorMessage {
                        Text(errorMessage)
                            .font(.system(size: 12))
                            .foregroundStyle(SSColor.brand)
                    }

                    Button {
                        Task { await logIn() }
                    } label: {
                        HStack {
                            if isLoading {
                                ProgressView().tint(SSColor.brand)
                            } else {
                                Text("Sign in")
                            }
                        }
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(SSColor.brand)
                        .frame(maxWidth: .infinity)
                        .padding(13)
                    }
                    .neumorphicPressed()
                    .disabled(isLoading || email.isEmpty || password.isEmpty)

                    Button {
                        showForgotPassword = true
                    } label: {
                        Text("Forgot password?")
                            .font(.system(size: 12))
                            .foregroundStyle(SSColor.textSecondary)
                    }

                    Button {
                        showSignUp = true
                    } label: {
                        Text("Don't have an account? Sign up")
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
        .navigationDestination(isPresented: $showForgotPassword) {
            ForgotPasswordEmailView(dismissAll: $showForgotPassword)
        }
    }

    private func logIn() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        do {
            let response = try await AuthAPI.login(email: email, password: password)
            session.setSession(token: response.accessToken, user: response.userInfo)
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}

#Preview {
    LoginView(showSignUp: .constant(false))
        .environmentObject(SessionStore())
}

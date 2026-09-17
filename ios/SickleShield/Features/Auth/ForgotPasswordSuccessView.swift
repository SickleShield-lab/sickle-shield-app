import SwiftUI

struct ForgotPasswordSuccessView: View {
    @Binding var dismissAll: Bool

    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 56))
                .foregroundStyle(.green)
            Text("Password changed")
                .font(.system(size: 20, weight: .medium))
                .foregroundStyle(Theme.ink)
            Text("You can now sign in with your new password.")
                .font(.system(size: 13))
                .foregroundStyle(Theme.muted)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
            Spacer()

            Button {
                dismissAll = false
            } label: {
                Text("Back to sign in")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(Theme.accent)
                    .frame(maxWidth: .infinity)
                    .padding(13)
            }
            .neumorphicPressed()
            .padding(20)
        }
        .background(Theme.background.ignoresSafeArea())
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
    }
}

#Preview {
    NavigationStack {
        ForgotPasswordSuccessView(dismissAll: .constant(true))
    }
}

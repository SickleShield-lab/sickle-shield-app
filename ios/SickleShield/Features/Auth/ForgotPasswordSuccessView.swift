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
                .foregroundStyle(SSColor.textPrimary)
            Text("You can now sign in with your new password.")
                .font(.system(size: 13))
                .foregroundStyle(SSColor.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
            Spacer()

            Button {
                dismissAll = false
            } label: {
                Text("Back to sign in")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(SSColor.brand)
                    .frame(maxWidth: .infinity)
                    .padding(13)
            }
            .neumorphicPressed()
            .padding(20)
        }
        .background(SSColor.background.ignoresSafeArea())
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
    }
}

#Preview {
    NavigationStack {
        ForgotPasswordSuccessView(dismissAll: .constant(true))
    }
}

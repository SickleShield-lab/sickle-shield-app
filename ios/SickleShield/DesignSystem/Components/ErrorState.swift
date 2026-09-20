import SwiftUI

struct ErrorState: View {
    let message: String
    let retry: () -> Void

    var body: some View {
        VStack(spacing: 10) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 24))
                .foregroundStyle(SSColor.brand)
            Text(message)
                .font(.system(size: 12))
                .foregroundStyle(SSColor.textSecondary)
                .multilineTextAlignment(.center)
            Button("Try again", action: retry)
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(SSColor.brand)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .neumorphicPressed(radius: 12)
        }
        .padding(24)
    }
}

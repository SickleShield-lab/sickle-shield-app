import SwiftUI

/// The primary call-to-action style - filled brand red, white text.
struct SSPrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(.body, weight: .semibold))
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, SSSpacing.md + 1)
            .background(SSColor.brand)
            .clipShape(RoundedRectangle(cornerRadius: SSRadius.md, style: .continuous))
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
            .animation(.spring(response: 0.3, dampingFraction: 1), value: configuration.isPressed)
    }
}

/// The secondary style - neutral surface, primary text. For actions that
/// matter but shouldn't compete with the primary action on screen.
struct SSSecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(.body, weight: .semibold))
            .foregroundStyle(SSColor.textPrimary)
            .frame(maxWidth: .infinity)
            .padding(.vertical, SSSpacing.md + 1)
            .background(SSColor.surfaceSecondary)
            .clipShape(RoundedRectangle(cornerRadius: SSRadius.md, style: .continuous))
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
            .animation(.spring(response: 0.3, dampingFraction: 1), value: configuration.isPressed)
    }
}

extension ButtonStyle where Self == SSPrimaryButtonStyle {
    static var ssPrimary: SSPrimaryButtonStyle { SSPrimaryButtonStyle() }
}

extension ButtonStyle where Self == SSSecondaryButtonStyle {
    static var ssSecondary: SSSecondaryButtonStyle { SSSecondaryButtonStyle() }
}

#Preview {
    VStack(spacing: 12) {
        Button("Save now") {}.buttonStyle(.ssPrimary)
        Button("Skip for now") {}.buttonStyle(.ssSecondary)
    }
    .padding()
    .background(SSColor.background)
}

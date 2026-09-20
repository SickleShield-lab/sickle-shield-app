import SwiftUI

private struct NeumorphicRaised: ViewModifier {
    var radius: CGFloat
    @Environment(\.colorScheme) private var colorScheme

    func body(content: Content) -> some View {
        content
            .background(SSColor.surface)
            .clipShape(RoundedRectangle(cornerRadius: radius, style: .continuous))
            .shadow(color: .black.opacity(colorScheme == .dark ? 0.6 : 0.14), radius: 8, x: 5, y: 5)
            .shadow(color: .white.opacity(colorScheme == .dark ? 0.06 : 0.85), radius: 8, x: -5, y: -5)
    }
}

private struct NeumorphicPressed: ViewModifier {
    var radius: CGFloat
    @Environment(\.colorScheme) private var colorScheme

    func body(content: Content) -> some View {
        content
            .background(SSColor.surface)
            .clipShape(RoundedRectangle(cornerRadius: radius, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: radius, style: .continuous)
                    .stroke(Color.black.opacity(colorScheme == .dark ? 0.5 : 0.18), lineWidth: 4)
                    .blur(radius: 4)
                    .offset(x: 2, y: 2)
                    .blendMode(.multiply)
                    .clipShape(RoundedRectangle(cornerRadius: radius, style: .continuous))
            )
            .overlay(
                RoundedRectangle(cornerRadius: radius, style: .continuous)
                    .stroke(Color.white.opacity(colorScheme == .dark ? 0.05 : 0.75), lineWidth: 4)
                    .blur(radius: 4)
                    .offset(x: -2, y: -2)
                    .blendMode(.screen)
                    .clipShape(RoundedRectangle(cornerRadius: radius, style: .continuous))
            )
    }
}

extension View {
    func neumorphicCard(radius: CGFloat = Theme.cardRadius) -> some View {
        modifier(NeumorphicRaised(radius: radius))
    }

    func neumorphicPressed(radius: CGFloat = Theme.pillRadius) -> some View {
        modifier(NeumorphicPressed(radius: radius))
    }
}

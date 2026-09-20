import SwiftUI

private struct SSCardModifier: ViewModifier {
    var radius: CGFloat = SSRadius.md
    var padding: CGFloat? = SSSpacing.lg

    func body(content: Content) -> some View {
        content
            .padding(padding ?? 0)
            .background(SSColor.surface)
            .clipShape(RoundedRectangle(cornerRadius: radius, style: .continuous))
            .shadow(color: .black.opacity(0.05), radius: 6, x: 0, y: 1)
    }
}

extension View {
    /// The base surface for grouped content - a rounded, softly-shadowed
    /// card on `SSColor.surface`. Pass `padding: nil` when the content
    /// manages its own internal padding (e.g. a `List`-like stack of rows).
    func ssCard(radius: CGFloat = SSRadius.md, padding: CGFloat? = SSSpacing.lg) -> some View {
        modifier(SSCardModifier(radius: radius, padding: padding))
    }
}

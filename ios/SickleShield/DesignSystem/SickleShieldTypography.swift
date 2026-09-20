import SwiftUI

/// Dynamic-Type-based text styles - never a fixed point size, so text scales
/// with the user's preferred size. Tracking is size-specific per Apple's
/// typography guidance: tighten large text, leave body near zero, loosen
/// small text slightly.
private struct SSTextStyle: ViewModifier {
    let font: Font
    let tracking: CGFloat
    let color: Color

    func body(content: Content) -> some View {
        content
            .font(font)
            .tracking(tracking)
            .foregroundStyle(color)
    }
}

extension View {
    /// Large numeric/hero values (e.g. a metric card's headline number).
    func ssDisplay(color: Color = SSColor.textPrimary) -> some View {
        modifier(SSTextStyle(font: .system(.largeTitle, weight: .bold), tracking: -0.4, color: color))
    }

    /// Screen/section titles.
    func ssTitle(color: Color = SSColor.textPrimary) -> some View {
        modifier(SSTextStyle(font: .system(.title2, weight: .bold), tracking: -0.3, color: color))
    }

    /// Card headlines, row titles.
    func ssHeadline(color: Color = SSColor.textPrimary) -> some View {
        modifier(SSTextStyle(font: .system(.headline, weight: .semibold), tracking: -0.1, color: color))
    }

    /// Default body copy.
    func ssBody(color: Color = SSColor.textPrimary) -> some View {
        modifier(SSTextStyle(font: .system(.body), tracking: 0, color: color))
    }

    /// Secondary/supporting copy.
    func ssSubtext(color: Color = SSColor.textSecondary) -> some View {
        modifier(SSTextStyle(font: .system(.subheadline), tracking: 0.05, color: color))
    }

    /// Small captions, timestamps, meta text.
    func ssCaption(color: Color = SSColor.textMuted) -> some View {
        modifier(SSTextStyle(font: .system(.caption), tracking: 0.1, color: color))
    }

    /// Uppercase section labels ("TODAY", "QUICK LOG").
    func ssSectionLabel(color: Color = SSColor.textMuted) -> some View {
        modifier(SSTextStyle(font: .system(.caption2, weight: .bold), tracking: 0.6, color: color))
            .textCase(.uppercase)
    }
}

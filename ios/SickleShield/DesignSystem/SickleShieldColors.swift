import SwiftUI

/// Semantic, dark-mode-aware color tokens backed by Assets.xcassets color
/// sets. New screens should use these instead of `Theme`'s flat hex
/// constants, which don't adapt to appearance.
enum SSColor {
    static let background = Color("SSBackground")
    static let surface = Color("SSSurface")
    static let surfaceSecondary = Color("SSSurfaceSecondary")

    static let textPrimary = Color("SSTextPrimary")
    static let textSecondary = Color("SSTextSecondary")
    static let textMuted = Color("SSTextMuted")

    static let border = Color("SSBorder")

    /// Reserved for pain-related information, emergency actions, primary
    /// actions, and selected states - not general decoration.
    static let brand = Color("SSBrand")
    static let brandSoft = Color("SSBrandSoft")

    static let success = Color("SSSuccess")
    static let warning = Color("SSWarning")
    static let info = Color("SSInfo")
}

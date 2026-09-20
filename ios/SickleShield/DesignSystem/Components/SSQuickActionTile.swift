import SwiftUI

/// A single tappable entry in the Quick Log row/grid. `isSelected` fills
/// the tile solid instead of just tinting its icon/label - used by the
/// unified Quick Log page's category picker.
struct SSQuickActionTile: View {
    let systemImage: String
    let label: String
    var tint: Color = SSColor.brand
    var isSelected: Bool = false
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: SSSpacing.xs) {
                Image(systemName: systemImage)
                    .font(.system(.body, weight: .semibold))
                Text(label)
                    .font(.system(.caption2, weight: .semibold))
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
            }
            .foregroundStyle(isSelected ? .white : tint)
            .frame(maxWidth: .infinity)
            .padding(.vertical, SSSpacing.md)
            .background(isSelected ? tint : SSColor.surface)
            .clipShape(RoundedRectangle(cornerRadius: SSRadius.md, style: .continuous))
            .shadow(color: .black.opacity(0.05), radius: 6, x: 0, y: 1)
            .scaleEffect(isSelected ? 1.03 : 1)
        }
        .buttonStyle(.plain)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
        .accessibilityLabel(label)
        .accessibilityAddTraits(.isButton)
    }
}

#Preview {
    HStack(spacing: 10) {
        SSQuickActionTile(systemImage: "waveform.path.ecg", label: "Pain") {}
        SSQuickActionTile(systemImage: "drop.fill", label: "Water", isSelected: true) {}
        SSQuickActionTile(systemImage: "pills.fill", label: "Meds") {}
    }
    .padding()
    .background(SSColor.background)
}

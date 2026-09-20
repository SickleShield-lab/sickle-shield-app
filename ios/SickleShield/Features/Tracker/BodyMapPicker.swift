import SwiftUI

/// A drawn front-view body silhouette with tappable dot markers - turns
/// what used to be free text into structured, chartable location data.
/// Not anatomically precise, just proportional enough to read as a body.
/// "Back" and "Joints" aren't visible from a front silhouette, so they're
/// offered as two supplementary chips below the diagram.
struct BodyMapPicker: View {
    @Binding var selection: String?

    private struct BodyRegion: Identifiable {
        let region: String
        let point: CGPoint
        var id: String { region }
    }

    private let canvasSize = CGSize(width: 180, height: 300)

    private let dotPositions: [BodyRegion] = [
        BodyRegion(region: "Head", point: CGPoint(x: 90, y: 35)),
        BodyRegion(region: "Chest", point: CGPoint(x: 90, y: 105)),
        BodyRegion(region: "Left Arm", point: CGPoint(x: 35, y: 140)),
        BodyRegion(region: "Right Arm", point: CGPoint(x: 145, y: 140)),
        BodyRegion(region: "Abdomen", point: CGPoint(x: 90, y: 165)),
        BodyRegion(region: "Left Leg", point: CGPoint(x: 68, y: 245)),
        BodyRegion(region: "Right Leg", point: CGPoint(x: 112, y: 245)),
    ]

    var body: some View {
        VStack(spacing: SSSpacing.sm) {
            ZStack {
                silhouette
                ForEach(dotPositions) { entry in
                    dot(for: entry.region)
                        .position(entry.point)
                }
            }
            .frame(width: canvasSize.width, height: canvasSize.height)

            Text(selection.map { "Selected: \($0)" } ?? "Tap a body part to select it")
                .ssCaption()

            HStack(spacing: 6) {
                supplementaryChip("Back")
                supplementaryChip("Joints")
            }
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Silhouette

    private var silhouette: some View {
        ZStack {
            Circle() // head
                .frame(width: 50, height: 50)
                .position(x: 90, y: 35)
            RoundedRectangle(cornerRadius: 24, style: .continuous) // torso
                .frame(width: 80, height: 100)
                .position(x: 90, y: 130)
            Capsule() // left arm
                .frame(width: 22, height: 95)
                .position(x: 35, y: 140)
            Capsule() // right arm
                .frame(width: 22, height: 95)
                .position(x: 145, y: 140)
            Capsule() // left leg
                .frame(width: 28, height: 110)
                .position(x: 68, y: 245)
            Capsule() // right leg
                .frame(width: 28, height: 110)
                .position(x: 112, y: 245)
        }
        .foregroundStyle(SSColor.surfaceSecondary)
    }

    // MARK: - Dots

    private func dot(for region: String) -> some View {
        let isSelected = selection == region
        return Button {
            selection = isSelected ? nil : region
        } label: {
            Circle()
                .fill(isSelected ? SSColor.brand : SSColor.brand.opacity(0.45))
                .frame(width: isSelected ? 22 : 16, height: isSelected ? 22 : 16)
                .overlay {
                    Circle()
                        .stroke(SSColor.surface, lineWidth: isSelected ? 2 : 1)
                }
                .shadow(color: .black.opacity(0.15), radius: 2, y: 1)
        }
        .buttonStyle(.plain)
        .animation(.spring(response: 0.25, dampingFraction: 0.7), value: isSelected)
        .accessibilityLabel(region)
    }

    private func supplementaryChip(_ name: String) -> some View {
        let isSelected = selection == name
        return Button {
            selection = isSelected ? nil : name
        } label: {
            Text(name)
                .font(.system(size: 10, weight: isSelected ? .semibold : .regular))
                .foregroundStyle(SSColor.textPrimary)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background {
                    if isSelected {
                        Color.clear.neumorphicPressed(radius: 20)
                    } else {
                        Color.clear.neumorphicCard(radius: 20)
                    }
                }
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    @Previewable @State var selection: String?
    return BodyMapPicker(selection: $selection)
        .padding()
        .background(SSColor.background)
}

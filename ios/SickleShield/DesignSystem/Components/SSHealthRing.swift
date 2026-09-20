import SwiftUI

/// A circular progress ring with a value and label in the center - used
/// anywhere a single metric is best read as "how much of a goal," e.g.
/// hydration, medication adherence, crisis risk.
struct SSHealthRing: View {
    /// 0...1
    let progress: Double
    let value: String
    let label: String
    var tint: Color = SSColor.brand
    var lineWidth: CGFloat = 10

    var body: some View {
        ZStack {
            Circle()
                .stroke(SSColor.surfaceSecondary, lineWidth: lineWidth)
            Circle()
                .trim(from: 0, to: min(max(progress, 0), 1))
                .stroke(tint, style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .animation(.spring(response: 0.4, dampingFraction: 1), value: progress)
            VStack(spacing: 2) {
                Text(value)
                    .font(.system(.title, weight: .bold))
                    .tracking(-0.3)
                    .foregroundStyle(SSColor.textPrimary)
                Text(label)
                    .ssCaption()
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(label)
        .accessibilityValue(value)
    }
}

#Preview {
    SSHealthRing(progress: 0.7, value: "1.4L", label: "of 2.0L")
        .frame(width: 160, height: 160)
        .padding()
        .background(SSColor.background)
}

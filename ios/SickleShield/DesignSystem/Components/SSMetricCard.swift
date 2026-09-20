import SwiftUI

/// A single at-a-glance metric (e.g. "2/10 Pain - Typical for you"). Tap
/// action is optional - pass one to make the whole card navigable.
struct SSMetricCard: View {
    let systemImage: String
    let value: String
    let label: String
    let sub: String?
    var accent: Color = SSColor.textSecondary
    var action: (() -> Void)? = nil

    var body: some View {
        Group {
            if let action {
                Button(action: action) { content }
                    .buttonStyle(.plain)
            } else {
                content
            }
        }
    }

    private var content: some View {
        VStack(alignment: .leading, spacing: SSSpacing.xs) {
            Image(systemName: systemImage)
                .font(.system(.subheadline))
                .foregroundStyle(accent)
            Text(value)
                .font(.system(.title3, weight: .bold))
                .tracking(-0.2)
                .foregroundStyle(accent == SSColor.textSecondary ? SSColor.textPrimary : accent)
            Text(label)
                .ssCaption(color: SSColor.textPrimary)
            if let sub {
                Text(sub)
                    .ssCaption()
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .ssCard(radius: SSRadius.md, padding: SSSpacing.md)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(label)
        .accessibilityValue(sub.map { "\(value), \($0)" } ?? value)
    }
}

#Preview {
    HStack(spacing: 10) {
        SSMetricCard(systemImage: "waveform.path.ecg", value: "2/10", label: "Pain", sub: "Typical for you", accent: SSColor.brand)
        SSMetricCard(systemImage: "drop.fill", value: "1.4L", label: "Hydration", sub: "6 glasses")
        SSMetricCard(systemImage: "pills.fill", value: "3/3", label: "Meds", sub: "Taken today")
    }
    .padding()
    .background(SSColor.background)
}

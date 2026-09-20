import SwiftUI

/// A single observation surfaced to the user - e.g. on Today ("your pain has
/// been lower than usual") or in the Insights list. `kind` is shown as an
/// explicit tag so an observation is never mistaken for a diagnosis.
enum SSInsightKind: String {
    case pattern = "Pattern"
    case data = "Data"

    var tint: Color {
        switch self {
        case .pattern: return SSColor.info
        case .data: return SSColor.success
        }
    }
}

struct SSInsightCard: View {
    let systemImage: String
    let text: String
    var kind: SSInsightKind? = nil
    var actionTitle: String? = nil
    var action: (() -> Void)? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: SSSpacing.sm) {
            HStack(alignment: .top, spacing: SSSpacing.sm) {
                Image(systemName: systemImage)
                    .font(.system(.body))
                    .foregroundStyle(SSColor.textSecondary)
                Text(text)
                    .ssBody()
                    .fixedSize(horizontal: false, vertical: true)
            }
            if let kind {
                Text(kind.rawValue)
                    .font(.system(.caption2, weight: .bold))
                    .textCase(.uppercase)
                    .padding(.horizontal, SSSpacing.sm)
                    .padding(.vertical, 3)
                    .background(kind.tint.opacity(0.15))
                    .foregroundStyle(kind.tint)
                    .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
            }
            if let actionTitle, let action {
                Button(action: action) {
                    Text(actionTitle + " →")
                        .font(.system(.footnote, weight: .bold))
                        .foregroundStyle(SSColor.brand)
                }
                .buttonStyle(.plain)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .ssCard()
    }
}

#Preview {
    VStack(spacing: 12) {
        SSInsightCard(systemImage: "chart.line.downtrend.xyaxis", text: "Your pain has been lower than your recent average.", actionTitle: "View trend") {}
        SSInsightCard(systemImage: "pills.fill", text: "Medication adherence was 91% this month.", kind: .data)
    }
    .padding()
    .background(SSColor.background)
}

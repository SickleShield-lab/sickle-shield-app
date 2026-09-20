import SwiftUI

/// One entry in a chronological "your day" / health timeline.
struct SSTimelineRow: View {
    let time: String
    let text: String
    var isLast: Bool = false

    var body: some View {
        HStack(alignment: .top, spacing: SSSpacing.md) {
            VStack(spacing: 0) {
                Circle()
                    .fill(SSColor.brand)
                    .frame(width: 8, height: 8)
                    .padding(.top, 5)
                if !isLast {
                    Rectangle()
                        .fill(SSColor.border)
                        .frame(width: 2)
                }
            }
            VStack(alignment: .leading, spacing: 2) {
                Text(time)
                    .font(.system(.caption2, weight: .semibold))
                    .foregroundStyle(SSColor.textMuted)
                Text(text)
                    .ssBody()
            }
            .padding(.bottom, isLast ? 0 : SSSpacing.md)
        }
        .accessibilityElement(children: .combine)
    }
}

#Preview {
    VStack(alignment: .leading, spacing: 0) {
        SSTimelineRow(time: "08:00", text: "Medication taken")
        SSTimelineRow(time: "11:20", text: "500ml water logged")
        SSTimelineRow(time: "14:10", text: "Pain 2/10 logged", isLast: true)
    }
    .padding()
    .background(SSColor.background)
}

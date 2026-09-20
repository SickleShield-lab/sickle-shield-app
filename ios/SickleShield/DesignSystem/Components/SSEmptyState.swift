import SwiftUI

/// A designed empty state - never a bare "No data." Every list-backed
/// screen (Pain, Medications, Appointments, Lab Results...) should use this
/// instead of a plain `Text`.
struct SSEmptyState: View {
    let systemImage: String
    let title: String
    let message: String
    var actionTitle: String? = nil
    var action: (() -> Void)? = nil

    var body: some View {
        VStack(spacing: SSSpacing.md) {
            Image(systemName: systemImage)
                .font(.system(size: 32))
                .foregroundStyle(SSColor.textMuted)
            Text(title)
                .ssHeadline()
            Text(message)
                .ssSubtext()
                .multilineTextAlignment(.center)
            if let actionTitle, let action {
                Button(actionTitle, action: action)
                    .buttonStyle(.ssPrimary)
                    .frame(maxWidth: 220)
                    .padding(.top, SSSpacing.sm)
            }
        }
        .padding(SSSpacing.xxl)
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    SSEmptyState(
        systemImage: "waveform.path.ecg",
        title: "No pain entries",
        message: "Start tracking your pain to see your patterns over time.",
        actionTitle: "Log Pain"
    ) {}
    .background(SSColor.background)
}

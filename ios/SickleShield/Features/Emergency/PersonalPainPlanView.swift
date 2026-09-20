import SwiftUI

/// Stored on-device only (no backend model for this exists - see the v2
/// redesign doc, which explicitly scopes this as local-only). Reused from
/// both Settings (calm authoring) and Crisis Mode (read during a crisis).
private let painPlanPlaceholder = """
Example:
1. Take my prescribed pain medication.
2. Apply a heating pad to the affected area.
3. Drink water steadily.
4. Rest somewhere quiet and warm.
5. If pain stays above 7/10 for more than 2 hours, call my care team.
"""

struct PersonalPainPlanView: View {
    @AppStorage("personalPainPlanText") private var planText = ""
    @Environment(\.dismiss) private var dismiss
    @FocusState private var isEditing: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: SSSpacing.sm) {
            Text("Write the steps you want to follow during a crisis, while you're calm enough to think it through.")
                .ssCaption()
                .padding(.horizontal, SSSpacing.lg)
                .padding(.top, SSSpacing.sm)

            TextEditor(text: $planText)
                .focused($isEditing)
                .font(.system(.body))
                .padding(SSSpacing.md)
                .background(SSColor.surface)
                .overlay(alignment: .topLeading) {
                    if planText.isEmpty {
                        Text(painPlanPlaceholder)
                            .foregroundStyle(SSColor.textMuted)
                            .padding(.horizontal, SSSpacing.md + 4)
                            .padding(.vertical, SSSpacing.md + 8)
                            .allowsHitTesting(false)
                    }
                }
                .padding(.horizontal, SSSpacing.lg)
                .padding(.bottom, SSSpacing.lg)
        }
        .background(SSColor.background.ignoresSafeArea())
        .navigationTitle("My Pain Plan")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Done") { dismiss() }
            }
        }
    }
}

#Preview {
    NavigationStack {
        PersonalPainPlanView()
    }
}

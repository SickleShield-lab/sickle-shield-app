import SwiftUI

struct NameReportSheet: View {
    @Binding var name: String
    let isSaving: Bool
    let errorMessage: String?
    let onSave: () async -> Void
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 14) {
                    LabeledField(label: "Report name") {
                        TextField("e.g. Blood test - Sep 2025", text: $name)
                    }
                    if let errorMessage {
                        Text(errorMessage)
                            .font(.system(size: 12))
                            .foregroundStyle(Theme.deepRed)
                    }
                    Button {
                        Task { await onSave() }
                    } label: {
                        HStack {
                            if isSaving {
                                ProgressView().tint(Theme.accent)
                            } else {
                                Text("Upload")
                            }
                        }
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(Theme.accent)
                        .frame(maxWidth: .infinity)
                        .padding(13)
                    }
                    .neumorphicPressed()
                    .disabled(isSaving || name.isEmpty)
                }
                .padding(20)
            }
            .background(Theme.background.ignoresSafeArea())
            .navigationTitle("Name this report")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }
}

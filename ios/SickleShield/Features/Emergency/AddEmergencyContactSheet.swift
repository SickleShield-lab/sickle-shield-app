import SwiftUI

struct AddEmergencyContactSheet: View {
    @Environment(\.dismiss) private var dismiss
    let onSave: (String, String) async -> Bool

    @State private var name = ""
    @State private var number = ""
    @State private var isSaving = false
    @State private var errorMessage: String?

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 14) {
                    LabeledField(label: "Name") {
                        TextField("e.g. Mum, Dr. Aisha", text: $name)
                    }
                    LabeledField(label: "Phone number") {
                        TextField("e.g. +44 7577 637432", text: $number)
                            .keyboardType(.phonePad)
                    }

                    if let errorMessage {
                        Text(errorMessage)
                            .font(.system(size: 12))
                            .foregroundStyle(Theme.deepRed)
                    }

                    Button {
                        Task {
                            isSaving = true
                            let saved = await onSave(name, number)
                            isSaving = false
                            if saved { dismiss() } else { errorMessage = "Couldn't save this contact. Try again." }
                        }
                    } label: {
                        HStack {
                            if isSaving {
                                ProgressView().tint(Theme.accent)
                            } else {
                                Text("Save contact")
                            }
                        }
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(Theme.accent)
                        .frame(maxWidth: .infinity)
                        .padding(13)
                    }
                    .neumorphicPressed()
                    .disabled(isSaving || name.isEmpty || number.isEmpty)
                }
                .padding(20)
            }
            .background(Theme.background.ignoresSafeArea())
            .navigationTitle("Emergency contact")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }
}

import SwiftUI

struct AddReminderSheet: View {
    @ObservedObject var viewModel: RemindersViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var name = ""
    @State private var type = ""
    @State private var amount = ""
    @State private var time = ""

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 14) {
                    LabeledField(label: "Medicine name") {
                        TextField("e.g. Vitamin D", text: $name)
                    }
                    LabeledField(label: "Type") {
                        TextField("e.g. Supplement, Pain relief", text: $type)
                    }
                    LabeledField(label: "Dose") {
                        TextField("e.g. 2000 IU", text: $amount)
                    }
                    LabeledField(label: "Time") {
                        TextField("e.g. 08:00 AM", text: $time)
                    }

                    if let errorMessage = viewModel.errorMessage {
                        Text(errorMessage)
                            .font(.system(size: 12))
                            .foregroundStyle(Theme.deepRed)
                    }

                    Button {
                        Task {
                            let saved = await viewModel.addReminder(
                                name: name, type: type, amount: amount, time: time
                            )
                            if saved { dismiss() }
                        }
                    } label: {
                        HStack {
                            if viewModel.isSaving {
                                ProgressView().tint(Theme.accent)
                            } else {
                                Text("Save reminder")
                            }
                        }
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(Theme.accent)
                        .frame(maxWidth: .infinity)
                        .padding(13)
                    }
                    .neumorphicPressed()
                    .disabled(viewModel.isSaving || name.isEmpty || type.isEmpty || amount.isEmpty || time.isEmpty)
                }
                .padding(20)
            }
            .background(Theme.background.ignoresSafeArea())
            .navigationTitle("Add medicine")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }
}

import SwiftUI

struct AddHospitalSheet: View {
    @Environment(\.dismiss) private var dismiss
    let onSave: (String, String) async -> Bool

    @State private var name = ""
    @State private var location = ""
    @State private var isSaving = false
    @State private var errorMessage: String?

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Hospital name", text: $name)
                    TextField("Location", text: $location)
                }
                if let errorMessage {
                    Text(errorMessage)
                        .foregroundStyle(.red)
                }
            }
            .navigationTitle("Add hospital")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button {
                        Task {
                            isSaving = true
                            let saved = await onSave(name, location)
                            isSaving = false
                            if saved { dismiss() } else { errorMessage = "Couldn't save this hospital. Try again." }
                        }
                    } label: {
                        if isSaving {
                            ProgressView()
                        } else {
                            Text("Save")
                        }
                    }
                    .disabled(isSaving || name.isEmpty || location.isEmpty)
                }
            }
        }
    }
}

#Preview {
    AddHospitalSheet { _, _ in true }
}

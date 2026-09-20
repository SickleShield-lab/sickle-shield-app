import SwiftUI

struct AddAppointmentSheet: View {
    @Environment(\.dismiss) private var dismiss
    let hospitals: [Hospital]
    let onSave: (String, String, Date, String, String) async -> Bool

    private static let shifts = ["Morning", "Afternoon", "Evening"]

    @State private var hospitalId: String
    @State private var doctorName = ""
    @State private var date = Date()
    @State private var shift = "Morning"
    @State private var time = Date()
    @State private var isSaving = false
    @State private var errorMessage: String?

    private static let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter
    }()

    init(hospitals: [Hospital], onSave: @escaping (String, String, Date, String, String) async -> Bool) {
        self.hospitals = hospitals
        self.onSave = onSave
        _hospitalId = State(initialValue: hospitals.first?.id ?? "")
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Picker("Hospital", selection: $hospitalId) {
                        ForEach(hospitals) { hospital in
                            Text(hospital.hospitalName).tag(hospital.id)
                        }
                    }
                    TextField("Doctor name (optional)", text: $doctorName)
                }
                Section {
                    DatePicker("Date", selection: $date, displayedComponents: .date)
                    Picker("Shift", selection: $shift) {
                        ForEach(Self.shifts, id: \.self) { Text($0) }
                    }
                    DatePicker("Time", selection: $time, displayedComponents: .hourAndMinute)
                }
                if let errorMessage {
                    Text(errorMessage)
                        .foregroundStyle(.red)
                }
            }
            .navigationTitle("Add appointment")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button {
                        Task {
                            isSaving = true
                            let saved = await onSave(hospitalId, doctorName, date, shift, Self.timeFormatter.string(from: time))
                            isSaving = false
                            if saved { dismiss() } else { errorMessage = "Couldn't book this appointment. Try again." }
                        }
                    } label: {
                        if isSaving {
                            ProgressView()
                        } else {
                            Text("Save")
                        }
                    }
                    .disabled(isSaving || hospitalId.isEmpty)
                }
            }
        }
    }
}

#Preview {
    AddAppointmentSheet(hospitals: []) { _, _, _, _, _ in true }
}

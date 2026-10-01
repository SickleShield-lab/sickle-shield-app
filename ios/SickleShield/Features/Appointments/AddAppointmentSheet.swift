import SwiftUI

struct AddAppointmentSheet: View {
    @Environment(\.dismiss) private var dismiss
    let hospitals: [Hospital]
    let onSave: (String, String, String, Date, String, String, Bool, Bool) async -> Bool

    private static let shifts = ["Morning", "Afternoon", "Evening"]
    private static let appointmentTypes = ["Follow Up", "Transfusion", "Chemotherapy", "Check-up", "Other"]

    @State private var hospitalId: String
    @State private var doctorName = ""
    @State private var type = "Follow Up"
    @State private var date = Date()
    @State private var shift = "Morning"
    @State private var time = Date()
    @State private var remindThreeDaysBefore = false
    @State private var remindTwoDaysBefore = false
    @State private var isSaving = false
    @State private var errorMessage: String?

    private static let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter
    }()

    init(hospitals: [Hospital], onSave: @escaping (String, String, String, Date, String, String, Bool, Bool) async -> Bool) {
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
                    Picker("Type", selection: $type) {
                        ForEach(Self.appointmentTypes, id: \.self) { Text($0) }
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
                Section {
                    Toggle("Remind me 3 days before", isOn: $remindThreeDaysBefore)
                    Toggle("Remind me 2 days before", isOn: $remindTwoDaysBefore)
                } footer: {
                    Text("You'll always get a reminder 24 hours before, plus any extra ones you turn on here.")
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
                            let saved = await onSave(
                                hospitalId, doctorName, type, date, shift, Self.timeFormatter.string(from: time),
                                remindThreeDaysBefore, remindTwoDaysBefore
                            )
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
    AddAppointmentSheet(hospitals: []) { _, _, _, _, _, _, _, _ in true }
}

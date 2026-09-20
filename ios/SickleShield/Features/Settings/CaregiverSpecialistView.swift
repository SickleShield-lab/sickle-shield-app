import SwiftUI

/// Optional, local-only (same tier as `PersonalPainPlanView` - no backend
/// model exists for this). When set, these show up as named call rows in
/// `CrisisModeView` instead of just the generic emergency contacts list.
struct CaregiverSpecialistView: View {
    @AppStorage("caregiverName") private var caregiverName = ""
    @AppStorage("caregiverPhone") private var caregiverPhone = ""
    @AppStorage("specialistName") private var specialistName = ""
    @AppStorage("specialistPhone") private var specialistPhone = ""
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        Form {
            Section("Caregiver") {
                TextField("Name", text: $caregiverName)
                TextField("Phone number", text: $caregiverPhone)
                    .keyboardType(.phonePad)
            }
            Section("Specialist") {
                TextField("Name", text: $specialistName)
                TextField("Phone number", text: $specialistPhone)
                    .keyboardType(.phonePad)
            }
        }
        .navigationTitle("Caregiver & Specialist")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Done") { dismiss() }
            }
        }
        .safeAreaInset(edge: .bottom) {
            Text("Both are optional. If you add a phone number, it appears as a quick-call row in Crisis Mode.")
                .ssCaption()
                .padding()
                .frame(maxWidth: .infinity)
        }
    }
}

#Preview {
    NavigationStack {
        CaregiverSpecialistView()
    }
}

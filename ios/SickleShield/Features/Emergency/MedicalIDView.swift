import SwiftUI

/// Read-only, built entirely from fields already collected on `User` plus
/// the first saved emergency contact - no new backend model needed.
struct MedicalIDView: View {
    @EnvironmentObject private var session: SessionStore
    @Environment(\.dismiss) private var dismiss
    @State private var firstContact: EmergencyContact?

    private var user: User? { session.currentUser }

    var body: some View {
        List {
            Section("Personal") {
                row("Name", user?.username)
                row("Date of birth", user?.dob)
                row("Gender", user?.gender)
            }
            Section("Medical") {
                row("Blood group", user?.bloodGroup)
                row("Diagnosis", user?.diagnosis)
            }
            Section("Contact") {
                row("Phone", user?.mobileNumber)
                if let firstContact {
                    row("Emergency contact", "\(firstContact.contactName) · \(firstContact.contactNumber)")
                }
            }
        }
        .navigationTitle("Medical ID")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Done") { dismiss() }
            }
        }
        .task {
            firstContact = try? await HospitalAPI.emergencyContacts().contacts.first
        }
    }

    private func row(_ label: String, _ value: String?) -> some View {
        HStack {
            Text(label)
                .foregroundStyle(SSColor.textSecondary)
            Spacer()
            Text((value?.isEmpty ?? true) ? "Not set" : value!)
                .foregroundStyle(SSColor.textPrimary)
                .multilineTextAlignment(.trailing)
        }
    }
}

#Preview {
    NavigationStack {
        MedicalIDView()
            .environmentObject(SessionStore())
    }
}

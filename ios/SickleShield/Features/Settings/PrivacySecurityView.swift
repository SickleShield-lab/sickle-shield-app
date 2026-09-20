import SwiftUI
import UIKit

struct PrivacySecurityView: View {
    @State private var showDeleteConfirmation = false

    var body: some View {
        List {
            Section {
                Text("""
                Sickle Shield stores your pain, hydration, medication, and appointment logs so they're available across your devices and can be shown back to you as trends. Your data is never sold or shared with third parties.

                Location is only used at the moment you send an SOS message, to include a map link for your emergency contacts - it isn't tracked in the background.
                """)
                .foregroundStyle(SSColor.textSecondary)
            }

            Section {
                Button("Delete Account", role: .destructive) {
                    showDeleteConfirmation = true
                }
            } footer: {
                Text("Account deletion is handled by our support team - this opens an email pre-addressed to them.")
            }
        }
        .navigationTitle("Privacy & Security")
        .navigationBarTitleDisplayMode(.inline)
        .confirmationDialog(
            "Deleting your account removes your data permanently. Continue by emailing support?",
            isPresented: $showDeleteConfirmation,
            titleVisibility: .visible
        ) {
            Button("Email Support", role: .destructive) {
                if let url = URL(string: "mailto:support@sickleshield.com?subject=Delete%20my%20account") {
                    UIApplication.shared.open(url)
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        PrivacySecurityView()
    }
}

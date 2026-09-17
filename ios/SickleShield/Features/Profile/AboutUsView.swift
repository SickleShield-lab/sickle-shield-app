import SwiftUI

struct AboutUsView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Sickle Shield")
                    .font(.title.weight(.semibold))
                Text("""
                Sickle Shield helps people living with sickle cell disease track crises, medications, hydration, and appointments in one place, and reach help fast during an emergency.

                This app is informational and does not replace medical advice. Always follow guidance from your care team.
                """)
                .font(.body)
                .foregroundStyle(.secondary)

                Text("Contact")
                    .font(.headline)
                    .padding(.top, 8)
                Link("support@sickleshield.com", destination: URL(string: "mailto:support@sickleshield.com")!)
            }
            .padding()
        }
        .navigationTitle("About us")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        AboutUsView()
    }
}

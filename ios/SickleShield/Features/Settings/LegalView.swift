import SwiftUI

struct LegalView: View {
    var body: some View {
        List {
            Section {
                NavigationLink("Privacy Policy") {
                    LegalDocumentView(title: "Privacy Policy", text: Self.privacyPolicyText)
                }
                NavigationLink("Terms & Conditions") {
                    LegalDocumentView(title: "Terms & Conditions", text: Self.termsText)
                }
            }
            Section {
                HStack {
                    Text("Version")
                    Spacer()
                    Text(Self.versionString)
                        .foregroundStyle(SSColor.textSecondary)
                }
            }
        }
        .navigationTitle("Legal")
        .navigationBarTitleDisplayMode(.inline)
    }

    private static var versionString: String {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
        let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
        return "\(version) (\(build))"
    }

    private static let privacyPolicyText = """
    Sickle Shield collects the health information you choose to log - pain episodes, medications, hydration, weight, mood, and appointments - so it can be shown back to you as trends and used to power features like your crisis risk score.

    Your data is stored securely and is never sold or shared with third parties. Location is only used at the moment you send an SOS message. You can request deletion of your account and data at any time from Settings > Privacy & Security.
    """

    private static let termsText = """
    Sickle Shield is an informational companion app for people living with sickle cell disease and does not replace professional medical advice, diagnosis, or treatment. Always consult your care team about your specific condition and before making any changes based on information in this app.

    By using Sickle Shield you agree to use it as a personal tracking and organizational tool, not as a substitute for emergency medical services in a crisis.
    """
}

private struct LegalDocumentView: View {
    let title: String
    let text: String

    var body: some View {
        ScrollView {
            Text(text)
                .ssBody()
                .padding()
        }
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        LegalView()
    }
}

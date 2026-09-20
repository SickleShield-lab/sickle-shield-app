import SwiftUI

private struct FAQItem: Identifiable {
    let id = UUID()
    let question: String
    let answer: String
}

private let faqs: [FAQItem] = [
    FAQItem(question: "How does the crisis risk score work?", answer: "It's a transparent heuristic computed from your own recent pain history, hydration, local weather, and (if you've granted access) heart rate and blood oxygen - never a diagnosis, and never sent anywhere for AI processing off your device."),
    FAQItem(question: "Where is my Personal Pain Plan stored?", answer: "On your device only, so you can write it down while calm and have it ready during a crisis. It isn't backed up to our servers, so it won't carry over automatically if you switch phones."),
    FAQItem(question: "Why didn't I get a text after tapping SOS?", answer: "SOS opens the Messages app pre-addressed to your emergency contacts with your location - you still need to tap Send. Make sure you have at least one emergency contact saved under Settings."),
    FAQItem(question: "Can I export my pain history for a doctor's visit?", answer: "Yes - open the Tracker tab and tap Export next to the trend chart to generate a PDF with your entries and trend chart."),
]

struct SupportView: View {
    var body: some View {
        List {
            Section("FAQs") {
                ForEach(faqs) { faq in
                    DisclosureGroup(faq.question) {
                        Text(faq.answer)
                            .foregroundStyle(SSColor.textSecondary)
                            .padding(.top, SSSpacing.xs)
                    }
                }
            }

            Section {
                Text("Need help with something else? Reach out - we usually reply within a day.")
                    .foregroundStyle(SSColor.textSecondary)
                Link("Send us a message", destination: URL(string: "mailto:support@sickleshield.com")!)
            }
        }
        .navigationTitle("Help")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        SupportView()
    }
}

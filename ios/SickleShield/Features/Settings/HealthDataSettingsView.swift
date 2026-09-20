import SwiftUI
import UIKit

struct HealthDataSettingsView: View {
    @State private var isRequesting = false

    var body: some View {
        List {
            Section {
                Label("Heart rate", systemImage: "heart.fill")
                Label("Blood oxygen", systemImage: "waveform.path.ecg")
                Label("Sleep", systemImage: "bed.double.fill")
            } header: {
                Text("What Sickle Shield reads")
            } footer: {
                Text("Heart rate and blood oxygen feed into your crisis risk score on the Today tab. Sleep is used on the Insights page to show your typical sleep and whether short sleep lines up with your pain days. Sickle Shield never writes data to Health.")
            }

            Section {
                Button {
                    Task {
                        isRequesting = true
                        async let vitals = HealthKitManager().latestVitals()
                        async let sleep = HealthKitManager().sleepHistory(days: 1)
                        _ = await (vitals, sleep)
                        isRequesting = false
                    }
                } label: {
                    if isRequesting {
                        ProgressView()
                    } else {
                        Text("Grant Access")
                    }
                }
                .disabled(isRequesting)

                Button("Manage in Health App") {
                    if let url = URL(string: "x-apple-health://") {
                        UIApplication.shared.open(url)
                    }
                }
            }
        }
        .navigationTitle("Health Data")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        HealthDataSettingsView()
    }
}

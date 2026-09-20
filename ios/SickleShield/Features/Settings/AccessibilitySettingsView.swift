import SwiftUI
import UIKit

struct AccessibilitySettingsView: View {
    var body: some View {
        List {
            Section {
                Text("Text throughout Sickle Shield scales automatically with the text size you choose in iOS Settings, including larger accessibility sizes. Screen reader labels are provided for interactive elements throughout the app.")
                    .foregroundStyle(SSColor.textSecondary)
            }
            Section {
                Button("Open Text Size Settings") {
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(url)
                    }
                }
            }
        }
        .navigationTitle("Accessibility")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        AccessibilitySettingsView()
    }
}

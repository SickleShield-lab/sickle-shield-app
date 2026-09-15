import SwiftUI

struct RootTabView: View {
    var body: some View {
        TabView {
            ExploreView()
                .tabItem { Label("Explore", systemImage: "house.fill") }
            TrackerView()
                .tabItem { Label("Tracker", systemImage: "waveform.path.ecg") }
            ReportsView()
                .tabItem { Label("Reports", systemImage: "doc.text.fill") }
            RemindersView()
                .tabItem { Label("Reminders", systemImage: "bell.fill") }
            EmergencyView()
                .tabItem { Label("Emergency", systemImage: "phone.fill") }
        }
        .tint(Theme.deepRed)
    }
}

import SwiftUI

struct RootTabView: View {
    @Environment(AppRouter.self) private var router

    var body: some View {
        @Bindable var router = router
        TabView(selection: $router.selectedTab) {
            ExploreView()
                .tabItem { Label("Explore", systemImage: "house.fill") }
                .tag(AppTab.explore)
            TrackerView()
                .tabItem { Label("Tracker", systemImage: "waveform.path.ecg") }
                .tag(AppTab.tracker)
            ReportsView()
                .tabItem { Label("Reports", systemImage: "doc.text.fill") }
                .tag(AppTab.reports)
            RemindersView()
                .tabItem { Label("Reminders", systemImage: "bell.fill") }
                .tag(AppTab.reminders)
            EmergencyView()
                .tabItem { Label("Emergency", systemImage: "phone.fill") }
                .tag(AppTab.emergency)
        }
        .tint(Theme.deepRed)
    }
}

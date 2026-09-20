import SwiftUI

struct RootTabView: View {
    @Environment(AppRouter.self) private var router

    var body: some View {
        @Bindable var router = router
        TabView(selection: $router.selectedTab) {
            TodayView()
                .tabItem { Label("Today", systemImage: "house.fill") }
                .tag(AppTab.today)
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
        .tint(SSColor.brand)
    }
}

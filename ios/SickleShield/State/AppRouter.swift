import SwiftUI

enum AppTab: Hashable {
    case today, tracker, reports, reminders, emergency
}

@Observable
final class AppRouter {
    var selectedTab: AppTab = .today
    /// Set by Today's "Log crisis" quick action; TrackerView clears it once it has opened its log form.
    var pendingCrisisLog = false

    func logCrisis() {
        selectedTab = .tracker
        pendingCrisisLog = true
    }
}

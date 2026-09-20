import SwiftUI

struct AppRootView: View {
    @StateObject private var session = SessionStore()
    @State private var router = AppRouter()
    @State private var setupDismissed = false
    @AppStorage("hasOnboarded") private var hasOnboarded = false
    @AppStorage("appAppearance") private var appearanceRaw = AppAppearance.system.rawValue
    @Environment(\.scenePhase) private var scenePhase

    private var needsProfileSetup: Bool {
        guard let user = session.currentUser else { return false }
        let gender = user.gender ?? ""
        let weight = user.weight ?? ""
        let bloodGroup = user.bloodGroup ?? ""
        return gender.isEmpty && weight.isEmpty && bloodGroup.isEmpty
    }

    var body: some View {
        Group {
            if !hasOnboarded {
                OnboardingView { hasOnboarded = true }
            } else if session.isAuthenticated {
                RootTabView()
            } else {
                AuthRootView()
            }
        }
        .environmentObject(session)
        .environment(router)
        .preferredColorScheme(AppAppearance(rawValue: appearanceRaw)?.colorScheme)
        .task {
            await session.refreshProfile()
        }
        .onChange(of: scenePhase) { _, newPhase in
            guard newPhase == .active, session.isAuthenticated else { return }
            Task {
                await LocalNotificationScheduler.requestAuthorizationIfNeeded()
                LocalNotificationScheduler.syncDailyCheckIn()
                if let status = try? await GoalAPI.waterIntake() {
                    LocalNotificationScheduler.syncWaterReminders(amount: status.amount, target: status.target)
                }
            }
        }
        .fullScreenCover(isPresented: Binding(
            get: { session.isAuthenticated && needsProfileSetup && !setupDismissed },
            set: { if !$0 { setupDismissed = true } }
        )) {
            SetUpProfileView { setupDismissed = true }
                .environmentObject(session)
        }
    }
}

#Preview {
    AppRootView()
}

import SwiftUI

struct AppRootView: View {
    @StateObject private var session = SessionStore()

    var body: some View {
        Group {
            if session.isAuthenticated {
                RootTabView()
            } else {
                AuthRootView()
            }
        }
        .environmentObject(session)
        .task {
            await session.refreshProfile()
        }
    }
}

#Preview {
    AppRootView()
}

import SwiftUI

struct AppRootView: View {
    @StateObject private var session = SessionStore()
    @State private var router = AppRouter()

    var body: some View {
        Group {
            if session.isAuthenticated {
                RootTabView()
            } else {
                AuthRootView()
            }
        }
        .environmentObject(session)
        .environment(router)
        .task {
            await session.refreshProfile()
        }
    }
}

#Preview {
    AppRootView()
}

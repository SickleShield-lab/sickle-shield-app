import SwiftUI

struct ProfileView: View {
    @EnvironmentObject private var session: SessionStore
    @State private var showLogoutConfirmation = false

    var body: some View {
        List {
            Section {
                HStack(spacing: 14) {
                    Circle()
                        .fill(Theme.accent.opacity(0.15))
                        .frame(width: 52, height: 52)
                        .overlay {
                            Text(initials)
                                .font(.headline)
                                .foregroundStyle(Theme.accent)
                        }
                    VStack(alignment: .leading, spacing: 2) {
                        Text(session.currentUser?.username ?? "—")
                            .font(.headline)
                        Text(session.currentUser?.email ?? "—")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }
                .padding(.vertical, 4)
            }

            Section {
                NavigationLink("Edit profile") {
                    EditProfileView()
                }
                NavigationLink("About us") {
                    AboutUsView()
                }
            }

            Section {
                Button("Log out", role: .destructive) {
                    showLogoutConfirmation = true
                }
            }
        }
        .navigationTitle("Profile")
        .confirmationDialog("Are you sure you want to log out?", isPresented: $showLogoutConfirmation, titleVisibility: .visible) {
            Button("Log out", role: .destructive) {
                session.logOut()
            }
        }
    }

    private var initials: String {
        guard let username = session.currentUser?.username, let first = username.first else { return "?" }
        return String(first).uppercased()
    }
}

#Preview {
    NavigationStack {
        ProfileView()
            .environmentObject(SessionStore())
    }
}

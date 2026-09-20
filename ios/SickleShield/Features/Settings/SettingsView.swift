import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var session: SessionStore
    @Environment(AppRouter.self) private var router
    @Environment(\.dismiss) private var dismiss
    @State private var showLogoutConfirmation = false

    var body: some View {
        List {
            Section {
                HStack(spacing: 14) {
                    Circle()
                        .fill(SSColor.brand.opacity(0.15))
                        .frame(width: 52, height: 52)
                        .overlay {
                            Text(initials)
                                .font(.headline)
                                .foregroundStyle(SSColor.brand)
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

            Section("Health") {
                NavigationLink {
                    EditProfileView()
                } label: {
                    SettingsIconLabel(systemImage: "person.crop.circle.fill", tint: .blue, title: "Health Profile")
                }
                NavigationLink {
                    HealthDataSettingsView()
                } label: {
                    SettingsIconLabel(systemImage: "heart.fill", tint: .pink, title: "Health Data & Apple Health")
                }
                NavigationLink {
                    PersonalPainPlanView()
                } label: {
                    SettingsIconLabel(systemImage: "heart.text.square.fill", tint: .red, title: "My Pain Plan")
                }
                NavigationLink {
                    MedicalIDView()
                } label: {
                    SettingsIconLabel(systemImage: "cross.case.fill", tint: .red, title: "Medical ID")
                }
                NavigationLink {
                    CaregiverSpecialistView()
                } label: {
                    SettingsIconLabel(systemImage: "person.2.fill", tint: .orange, title: "Caregiver & Specialist")
                }
            }

            Section("Safety & Care") {
                Button {
                    dismiss()
                    router.selectedTab = .emergency
                } label: {
                    SettingsIconLabel(systemImage: "phone.fill", tint: .red, title: "Emergency & Safety")
                }
                Button {
                    dismiss()
                    router.selectedTab = .reminders
                } label: {
                    SettingsIconLabel(systemImage: "pills.fill", tint: .orange, title: "Medications")
                }
                NavigationLink {
                    NotificationPreferencesView()
                } label: {
                    SettingsIconLabel(systemImage: "bell.fill", tint: .red, title: "Notifications")
                }
            }

            Section("Preferences") {
                NavigationLink {
                    AppearanceSettingsView()
                } label: {
                    SettingsIconLabel(systemImage: "circle.lefthalf.filled", tint: .gray, title: "Appearance")
                }
                NavigationLink {
                    AccessibilitySettingsView()
                } label: {
                    SettingsIconLabel(systemImage: "accessibility", tint: .blue, title: "Accessibility")
                }
            }

            Section("About") {
                NavigationLink {
                    AboutUsView()
                } label: {
                    SettingsIconLabel(systemImage: "info.circle.fill", tint: .gray, title: "About us")
                }
                NavigationLink {
                    SupportView()
                } label: {
                    SettingsIconLabel(systemImage: "questionmark.circle.fill", tint: .blue, title: "Help")
                }
                NavigationLink {
                    LegalView()
                } label: {
                    SettingsIconLabel(systemImage: "doc.text.fill", tint: .gray, title: "Legal")
                }
            }

            Section("Devices") {
                NavigationLink {
                    LinkedDevicesView()
                } label: {
                    SettingsIconLabel(systemImage: "applewatch", tint: .gray, title: "Linked Devices")
                }
            }

            Section("Account") {
                NavigationLink {
                    PrivacySecurityView()
                } label: {
                    SettingsIconLabel(systemImage: "lock.fill", tint: .gray, title: "Privacy & Security")
                }
                NavigationLink {
                    ChangePasswordView()
                } label: {
                    SettingsIconLabel(systemImage: "key.fill", tint: .yellow, title: "Change Password")
                }
                Button {
                    showLogoutConfirmation = true
                } label: {
                    SettingsIconLabel(systemImage: "rectangle.portrait.and.arrow.right", tint: .red, title: "Log out")
                        .foregroundStyle(.red)
                }
            }
        }
        .navigationTitle("Settings")
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
        SettingsView()
            .environmentObject(SessionStore())
            .environment(AppRouter())
    }
}

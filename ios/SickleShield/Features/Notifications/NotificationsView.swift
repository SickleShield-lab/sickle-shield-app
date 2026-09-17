import SwiftUI

struct NotificationsView: View {
    @State private var viewModel = NotificationsViewModel()

    private static let relativeFormatter: RelativeDateTimeFormatter = {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .short
        return formatter
    }()

    var body: some View {
        List {
            if let errorMessage = viewModel.errorMessage {
                ContentUnavailableView {
                    Label("Couldn't load notifications", systemImage: "exclamationmark.triangle")
                } description: {
                    Text(errorMessage)
                } actions: {
                    Button("Try again") { Task { await viewModel.load() } }
                }
            } else if viewModel.notifications.isEmpty {
                ContentUnavailableView(
                    "No notifications yet",
                    systemImage: "bell",
                    description: Text("We'll let you know when there's something new.")
                )
            } else {
                ForEach(viewModel.notifications) { notification in
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Text(notification.title)
                                .font(.headline)
                            if !notification.read {
                                Circle()
                                    .fill(Theme.accent)
                                    .frame(width: 8, height: 8)
                            }
                        }
                        Text(notification.body)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        Text(Self.relativeFormatter.localizedString(for: notification.createdAt, relativeTo: Date()))
                            .font(.caption)
                            .foregroundStyle(.tertiary)
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle("Notifications")
        .task { await viewModel.load() }
        .refreshable { await viewModel.load() }
    }
}

#Preview {
    NavigationStack {
        NotificationsView()
    }
}

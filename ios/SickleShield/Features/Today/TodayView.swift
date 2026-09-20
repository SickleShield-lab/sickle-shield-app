import SwiftUI

enum TodayDestination: Hashable {
    case hospitals, appointments, resources, notifications, settings, weight, water, insights, pain
    case quickLog(QuickLogCategory?)
}

struct TodayView: View {
    @EnvironmentObject private var session: SessionStore
    @Environment(AppRouter.self) private var router
    @StateObject private var viewModel = TodayViewModel()
    @State private var path: [TodayDestination] = []
    @AppStorage("dismissedUpdateID") private var dismissedUpdateID = ""

    private var latestUpdate: ImportantUpdate? {
        guard let latest = ImportantUpdates.all.first, latest.id != dismissedUpdateID else { return nil }
        return latest
    }

    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, yyyy"
        return formatter
    }()
    private static let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter
    }()

    var body: some View {
        NavigationStack(path: $path) {
            ScrollView {
                VStack(alignment: .leading, spacing: SSSpacing.xxl) {
                    header

                    if let update = latestUpdate {
                        importantUpdateBanner(update)
                    }

                    if let errorMessage = viewModel.errorMessage, viewModel.user == nil {
                        SSEmptyState(
                            systemImage: "wifi.slash",
                            title: "Couldn't load your data",
                            message: errorMessage,
                            actionTitle: "Try again"
                        ) {
                            Task { await viewModel.load() }
                        }
                        .padding(.top, SSSpacing.xxxl)
                    } else {
                        statRow
                        quickLog

                        if !viewModel.todayTimeline.isEmpty {
                            todaySection
                        }

                        if let risk = viewModel.riskAssessment {
                            SSInsightCard(
                                systemImage: "waveform.path.ecg",
                                text: risk.explanation,
                                actionTitle: "View trend"
                            ) {
                                path.append(.insights)
                            }
                        }

                        if let appointment = viewModel.nextAppointment {
                            upcomingCard(appointment)
                        }

                        resourcesSection
                    }
                }
                .padding(SSSpacing.lg)
            }
            .background(SSColor.background.ignoresSafeArea())
            .task { await viewModel.load() }
            .refreshable { await viewModel.load() }
            .onChange(of: router.selectedTab) { _, tab in
                guard tab == .today else { return }
                Task { await viewModel.load() }
            }
            .navigationDestination(for: TodayDestination.self) { destination in
                switch destination {
                case .hospitals: HospitalsListView()
                case .appointments: AppointmentsListView()
                case .resources: EducationalResourcesView()
                case .notifications: NotificationsView()
                case .settings: SettingsView()
                case .weight: WeightView()
                case .water: WaterIntakeView()
                case .insights: InsightsView()
                case .pain: PainView()
                case .quickLog(let category):
                    QuickLogView(initialCategory: category) {
                        Task { await viewModel.load() }
                    }
                }
            }
        }
    }

    // MARK: - Sections

    private var header: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 2) {
                Text("\(greeting), \(displayName)")
                    .ssTitle()
                Text("Here's your health snapshot")
                    .ssSubtext()
            }
            Spacer()
            HStack(spacing: SSSpacing.sm) {
                Button { path.append(.notifications) } label: {
                    Image(systemName: "bell.fill")
                        .font(.system(.subheadline))
                        .foregroundStyle(SSColor.textPrimary)
                        .frame(width: 34, height: 34)
                        .background(SSColor.surface)
                        .clipShape(Circle())
                        .overlay(alignment: .topTrailing) {
                            if viewModel.hasUnreadNotifications {
                                Circle()
                                    .fill(SSColor.brand)
                                    .frame(width: 9, height: 9)
                                    .offset(x: -2, y: 2)
                            }
                        }
                }
                Button { path.append(.settings) } label: {
                    Image(systemName: "gearshape.fill")
                        .font(.system(.subheadline))
                        .foregroundStyle(SSColor.textPrimary)
                        .frame(width: 34, height: 34)
                        .background(SSColor.surface)
                        .clipShape(Circle())
                }
            }
            .buttonStyle(.plain)
        }
    }

    private var statRow: some View {
        HStack(spacing: SSSpacing.sm) {
            SSMetricCard(
                systemImage: "waveform.path.ecg",
                value: painDisplay,
                label: "Pain",
                sub: "Recorded level",
                accent: SSColor.brand
            ) {
                path.append(.pain)
            }
            SSMetricCard(
                systemImage: "drop.fill",
                value: waterDisplay,
                label: "Hydration",
                sub: waterSub
            ) {
                path.append(.water)
            }
            SSMetricCard(
                systemImage: "pills.fill",
                value: reminderDisplay,
                label: "Reminders",
                sub: "active"
            ) {
                router.selectedTab = .reminders
            }
        }
        .redacted(reason: viewModel.isLoading && viewModel.user == nil ? .placeholder : [])
    }

    private var quickLog: some View {
        VStack(alignment: .leading, spacing: SSSpacing.sm) {
            HStack {
                Text("Quick Log")
                    .ssSectionLabel()
                Spacer()
                Button {
                    path.append(.quickLog(nil))
                } label: {
                    Image(systemName: "chevron.right")
                        .font(.system(.caption, weight: .bold))
                        .foregroundStyle(SSColor.brand)
                }
                .buttonStyle(.plain)
            }
            HStack(spacing: SSSpacing.sm) {
                SSQuickActionTile(systemImage: "waveform.path.ecg", label: "Pain") {
                    path.append(.quickLog(.pain))
                }
                SSQuickActionTile(systemImage: "cross.case.fill", label: "Hospitals") {
                    path.append(.hospitals)
                }
                SSQuickActionTile(systemImage: "calendar.badge.plus", label: "Appointments") {
                    path.append(.appointments)
                }
                SSQuickActionTile(systemImage: "scalemass.fill", label: "Weight") {
                    path.append(.quickLog(.weight))
                }
                SSQuickActionTile(systemImage: "heart.fill", label: "Mood") {
                    path.append(.quickLog(.mood))
                }
            }
        }
    }

    private var todaySection: some View {
        VStack(alignment: .leading, spacing: SSSpacing.sm) {
            Text("Your Day")
                .ssSectionLabel()
            VStack(alignment: .leading, spacing: 0) {
                ForEach(Array(viewModel.todayTimeline.enumerated()), id: \.element.id) { index, entry in
                    SSTimelineRow(
                        time: Self.timeFormatter.string(from: entry.date),
                        text: entry.text,
                        isLast: index == viewModel.todayTimeline.count - 1
                    )
                }
            }
            .ssCard()
        }
    }

    private func importantUpdateBanner(_ update: ImportantUpdate) -> some View {
        VStack(alignment: .leading, spacing: SSSpacing.sm) {
            Text("Important Updates")
                .ssSectionLabel()
            HStack(alignment: .top, spacing: SSSpacing.sm) {
                Image(systemName: "megaphone.fill")
                    .foregroundStyle(SSColor.brand)
                VStack(alignment: .leading, spacing: 2) {
                    Text(update.title)
                        .ssHeadline()
                    Text(update.body)
                        .ssSubtext()
                }
                Spacer()
                Button {
                    dismissedUpdateID = update.id
                } label: {
                    Image(systemName: "xmark")
                        .font(.system(.caption, weight: .bold))
                        .foregroundStyle(SSColor.textSecondary)
                }
                .buttonStyle(.plain)
            }
            .ssCard()
        }
    }

    private var resourcesSection: some View {
        VStack(alignment: .leading, spacing: SSSpacing.sm) {
            HStack {
                Text("Education")
                    .ssSectionLabel()
                Spacer()
                Button {
                    path.append(.resources)
                } label: {
                    Text("See all")
                        .font(.system(.caption, weight: .bold))
                        .foregroundStyle(SSColor.brand)
                }
                .buttonStyle(.plain)
            }
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: SSSpacing.sm) {
                    ForEach(viewModel.resources) { resource in
                        VStack(alignment: .leading, spacing: SSSpacing.xs) {
                            Image(systemName: "book.closed.fill")
                                .font(.system(.subheadline))
                                .foregroundStyle(SSColor.brand)
                            Text(resource.title)
                                .font(.system(.footnote, weight: .semibold))
                                .foregroundStyle(SSColor.textPrimary)
                                .lineLimit(2)
                            Text(resource.subTitle)
                                .ssCaption()
                                .lineLimit(1)
                        }
                        .frame(width: 140, alignment: .leading)
                        .ssCard(radius: SSRadius.md, padding: SSSpacing.md)
                    }
                }
            }
        }
    }

    private func upcomingCard(_ appointment: Appointment) -> some View {
        VStack(alignment: .leading, spacing: SSSpacing.sm) {
            Text("Upcoming")
                .ssSectionLabel()
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(viewModel.hospitalName(for: appointment))
                        .ssHeadline()
                    Text("\(Self.dateFormatter.string(from: appointment.date)) · \(appointment.time)")
                        .ssCaption()
                    if let doctorName = appointment.doctorName {
                        Text(doctorName)
                            .ssCaption()
                    }
                }
                Spacer()
                Image(systemName: "calendar")
                    .font(.system(.title3))
                    .foregroundStyle(SSColor.brand)
            }
            .ssCard()
        }
    }

    // MARK: - Derived display values

    private var greeting: String {
        switch Calendar.current.component(.hour, from: Date()) {
        case 0..<12: return "Good morning"
        case 12..<17: return "Good afternoon"
        default: return "Good evening"
        }
    }

    private var displayName: String {
        (viewModel.user ?? session.currentUser)?.username ?? "there"
    }

    private var painDisplay: String {
        guard let painManager = (viewModel.user ?? session.currentUser)?.painManager else { return "—" }
        return "\(painManager)/10"
    }

    private var waterDisplay: String {
        guard let status = viewModel.waterStatus else { return "—" }
        return "\(status.amount)/\(status.target)"
    }

    private var waterSub: String {
        guard let status = viewModel.waterStatus else { return "glasses today" }
        return "\(status.target - status.amount > 0 ? status.target - status.amount : 0) to go"
    }

    private var reminderDisplay: String {
        guard let count = viewModel.reminderCount else { return "—" }
        return "\(count)"
    }
}

#Preview {
    TodayView()
        .environmentObject(SessionStore())
        .environment(AppRouter())
}

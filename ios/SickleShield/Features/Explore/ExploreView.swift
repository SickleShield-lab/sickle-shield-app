import SwiftUI

struct ExploreView: View {
    @EnvironmentObject private var session: SessionStore
    @StateObject private var viewModel = ExploreViewModel()

    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, yyyy"
        return formatter
    }()

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                GlassHeader {
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Hello, \(displayName)")
                                .font(.system(size: 17, weight: .medium))
                                .foregroundStyle(.white)
                            Text("Your health at a glance")
                                .font(.system(size: 11))
                                .foregroundStyle(.white.opacity(0.85))
                        }
                        Spacer()
                        ZStack {
                            Circle().fill(Color.white.opacity(0.2)).frame(width: 32, height: 32)
                            Image(systemName: "bell.fill")
                                .font(.system(size: 14))
                                .foregroundStyle(.white)
                        }
                    }
                }
                .frame(height: 90)

                if let errorMessage = viewModel.errorMessage, viewModel.user == nil {
                    ErrorState(message: errorMessage) {
                        Task { await viewModel.load() }
                    }
                    .padding(.top, 40)
                } else {
                    VStack(alignment: .leading, spacing: 16) {
                        HStack(spacing: 10) {
                            StatTile(
                                value: painDisplay,
                                label: "Pain",
                                accent: Theme.accent
                            )
                            StatTile(
                                value: waterDisplay,
                                label: "Water"
                            )
                            StatTile(
                                value: weightDisplay,
                                label: "Weight"
                            )
                        }
                        .offset(y: -24)
                        .padding(.bottom, -24)
                        .redacted(reason: viewModel.isLoading && viewModel.user == nil ? .placeholder : [])

                        if let risk = viewModel.riskAssessment {
                            RiskScoreCard(assessment: risk)
                        }

                        VStack(alignment: .leading, spacing: 8) {
                            Text("Services")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundStyle(Theme.ink)
                            HStack(spacing: 10) {
                                ServiceTile(icon: "cross.case.fill", label: "Hospital")
                                ServiceTile(icon: "calendar", label: "Appt")
                                ServiceTile(icon: "bandage.fill", label: "Log crisis")
                            }
                        }

                        VStack(alignment: .leading, spacing: 8) {
                            Text("Upcoming appointment")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundStyle(Theme.ink)
                            if let appointment = viewModel.nextAppointment {
                                HStack {
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text("\(Self.dateFormatter.string(from: appointment.date)) · \(appointment.time)")
                                            .font(.system(size: 13, weight: .medium))
                                            .foregroundStyle(Theme.ink)
                                        if let doctorName = appointment.doctorName {
                                            Text(doctorName)
                                                .font(.system(size: 11))
                                                .foregroundStyle(Theme.muted)
                                        }
                                    }
                                    Spacer()
                                    Image(systemName: "calendar.badge.clock")
                                        .font(.system(size: 20))
                                        .foregroundStyle(Theme.accent)
                                }
                                .padding(14)
                                .neumorphicCard()
                            } else {
                                Text(viewModel.isLoading ? "Loading..." : "No upcoming appointments")
                                    .font(.system(size: 12))
                                    .foregroundStyle(Theme.muted)
                                    .padding(14)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .neumorphicCard()
                            }
                        }

                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text("Educational resources")
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundStyle(Theme.ink)
                                Spacer()
                                Text("See all")
                                    .font(.system(size: 11, weight: .medium))
                                    .foregroundStyle(Theme.deepRed)
                            }
                            if viewModel.resources.isEmpty {
                                Text(viewModel.isLoading ? "Loading..." : "No resources yet")
                                    .font(.system(size: 12))
                                    .foregroundStyle(Theme.muted)
                            } else {
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 10) {
                                        ForEach(viewModel.resources) { resource in
                                            ResourceCard(title: resource.title, subtitle: resource.subTitle)
                                        }
                                    }
                                }
                            }
                        }
                    }
                    .padding(16)
                }
            }
        }
        .background(Theme.background.ignoresSafeArea())
        .task {
            await viewModel.load()
        }
        .refreshable {
            await viewModel.load()
        }
    }

    private var displayName: String {
        (viewModel.user ?? session.currentUser)?.username ?? "there"
    }

    private var painDisplay: String {
        guard let painManager = (viewModel.user ?? session.currentUser)?.painManager else { return "—" }
        return String(format: "%.1f", Double(painManager))
    }

    private var waterDisplay: String {
        guard let user = viewModel.user ?? session.currentUser else { return "—" }
        let intake = user.lastIntake ?? 0
        let target = user.waterIntake ?? 10
        return "\(intake)/\(target)"
    }

    private var weightDisplay: String {
        guard let weight = (viewModel.user ?? session.currentUser)?.weight, !weight.isEmpty else { return "—" }
        return "\(weight)kg"
    }
}

private struct RiskScoreCard: View {
    let assessment: CrisisRiskAssessment

    private var levelColor: Color {
        switch assessment.level {
        case "Low": return Color(hex: "1D9E75")
        case "Moderate": return Color(hex: "E0A100")
        case "Elevated": return Theme.accent
        default: return Theme.deepRed
        }
    }

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .stroke(Theme.background, lineWidth: 6)
                Circle()
                    .trim(from: 0, to: CGFloat(assessment.score) / 100)
                    .stroke(levelColor, style: StrokeStyle(lineWidth: 6, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                Text("\(assessment.score)")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(Theme.ink)
            }
            .frame(width: 48, height: 48)

            VStack(alignment: .leading, spacing: 2) {
                Text("\(assessment.level) crisis risk today")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(Theme.ink)
                Text(assessment.explanation)
                    .font(.system(size: 10))
                    .foregroundStyle(Theme.muted)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(14)
        .neumorphicCard()
    }
}

private struct ResourceCard: View {
    let title: String
    let subtitle: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ZStack {
                RoundedRectangle(cornerRadius: 9, style: .continuous)
                    .fill(Theme.deepRed.opacity(0.12))
                    .frame(width: 28, height: 28)
                Image(systemName: "book.closed.fill")
                    .font(.system(size: 14))
                    .foregroundStyle(Theme.deepRed)
            }
            Text(title)
                .font(.system(size: 11, weight: .medium))
                .foregroundStyle(Theme.ink)
                .lineLimit(2)
            Text(subtitle)
                .font(.system(size: 9))
                .foregroundStyle(Theme.muted)
                .lineLimit(1)
        }
        .padding(12)
        .frame(width: 140, alignment: .leading)
        .neumorphicCard()
    }
}

#Preview {
    ExploreView()
        .environmentObject(SessionStore())
}

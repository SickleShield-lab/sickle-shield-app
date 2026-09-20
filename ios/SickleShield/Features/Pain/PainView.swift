import SwiftUI

struct PainView: View {
    @State private var viewModel = PainViewModel()
    @State private var selectedRange: PainRange = .thirtyDays

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: SSSpacing.xxl) {
                rangeSelector

                if viewModel.records.isEmpty && viewModel.isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity)
                        .padding(.top, 60)
                } else {
                    statsRow
                    if viewModel.records.count >= 2 {
                        trendCard
                    }
                    episodesSection
                }

                if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                        .ssCaption(color: SSColor.brand)
                }
            }
            .padding(SSSpacing.lg)
        }
        .background(SSColor.background.ignoresSafeArea())
        .navigationTitle("Pain")
        .task(id: selectedRange) {
            await viewModel.load(range: selectedRange)
        }
        .refreshable {
            await viewModel.load(range: selectedRange)
        }
    }

    private var rangeSelector: some View {
        HStack(spacing: 4) {
            ForEach(PainRange.allCases) { range in
                Button {
                    selectedRange = range
                } label: {
                    Text(range.rawValue)
                        .font(.system(.footnote, weight: .semibold))
                        .foregroundStyle(selectedRange == range ? SSColor.textPrimary : SSColor.textSecondary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, SSSpacing.sm)
                        .background(selectedRange == range ? SSColor.surface : Color.clear)
                        .clipShape(Capsule())
                }
                .buttonStyle(.plain)
            }
        }
        .padding(4)
        .background(SSColor.surfaceSecondary)
        .clipShape(Capsule())
    }

    private var statsRow: some View {
        HStack(spacing: SSSpacing.sm) {
            SSMetricCard(
                systemImage: "waveform.path.ecg",
                value: viewModel.records.isEmpty ? "—" : String(format: "%.1f", viewModel.average),
                label: "Average",
                sub: nil,
                accent: SSColor.brand
            )
            SSMetricCard(
                systemImage: "arrow.up.circle.fill",
                value: viewModel.records.isEmpty ? "—" : "\(viewModel.highest)",
                label: "Highest",
                sub: nil
            )
            SSMetricCard(
                systemImage: "arrow.down.circle.fill",
                value: viewModel.records.isEmpty ? "—" : "\(viewModel.lowest)",
                label: "Lowest",
                sub: nil
            )
            SSMetricCard(
                systemImage: "list.bullet.rectangle.fill",
                value: "\(viewModel.records.count)",
                label: "Episodes",
                sub: nil
            )
        }
    }

    private var trendCard: some View {
        VStack(alignment: .leading, spacing: SSSpacing.sm) {
            SSTrendLineChart(values: viewModel.records.map { Double($0.rating) })
                .frame(height: 100)
            Text(viewModel.summaryText)
                .ssBody()
        }
        .ssCard()
    }

    private var episodesSection: some View {
        VStack(alignment: .leading, spacing: SSSpacing.sm) {
            Text("Recent Episodes")
                .ssSectionLabel()
            if viewModel.records.isEmpty {
                Text(viewModel.isLoading ? "Loading..." : "No episodes recorded in this range.")
                    .ssCaption()
            } else {
                let recent = Array(viewModel.records.reversed().prefix(10))
                VStack(spacing: 0) {
                    ForEach(Array(recent.enumerated()), id: \.element.id) { index, entry in
                        episodeRow(entry, isLast: index == recent.count - 1)
                    }
                }
                .ssCard(padding: nil)
            }
        }
    }

    private func episodeRow(_ entry: PainEntry, isLast: Bool) -> some View {
        VStack(spacing: 0) {
            HStack(spacing: SSSpacing.md) {
                Circle()
                    .fill(SSColor.brandSoft)
                    .frame(width: 36, height: 36)
                    .overlay {
                        Text("\(entry.rating)")
                            .font(.system(.subheadline, weight: .bold))
                            .foregroundStyle(SSColor.brand)
                    }
                VStack(alignment: .leading, spacing: 2) {
                    Text(Self.dateTimeLabel(for: entry.createdAt))
                        .ssHeadline()
                    if !entry.pain.isEmpty {
                        Text(entry.pain)
                            .ssCaption()
                    }
                    if let medication = entry.medicationTaken {
                        Text("Took: \(medication)")
                            .ssCaption(color: SSColor.success)
                    }
                }
                Spacer()
            }
            .padding(SSSpacing.md)
            if !isLast {
                Divider()
                    .padding(.leading, SSSpacing.md + 36 + SSSpacing.md)
            }
        }
    }

    private static func dateTimeLabel(for date: Date) -> String {
        let calendar = Calendar.current
        let timeString = date.formatted(date: .omitted, time: .shortened)
        if calendar.isDateInToday(date) {
            return "Today, \(timeString)"
        }
        if calendar.isDateInYesterday(date) {
            return "Yesterday, \(timeString)"
        }
        if let daysAgo = calendar.dateComponents([.day], from: date, to: Date()).day, daysAgo < 7 {
            return "\(date.formatted(.dateTime.weekday(.abbreviated))), \(timeString)"
        }
        return "\(date.formatted(.dateTime.month(.abbreviated).day())), \(timeString)"
    }
}

#Preview {
    NavigationStack {
        PainView()
    }
}

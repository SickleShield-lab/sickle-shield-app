import SwiftUI

struct InsightsView: View {
    @State private var viewModel = InsightsViewModel()

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: SSSpacing.xxl) {
                if viewModel.records.isEmpty && viewModel.isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity)
                        .padding(.top, 60)
                } else {
                    baselineCard
                    if !viewModel.patterns.isEmpty {
                        patternsSection
                    }
                    statsRow
                    if viewModel.records.count >= 2 {
                        trendChart
                    }
                    if let insight = viewModel.insight {
                        summaryCard(insight)
                        tipsCard(insight)
                        crisisCard(insight)
                    }
                }
                if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                        .ssCaption(color: SSColor.brand)
                }
            }
            .padding(SSSpacing.lg)
        }
        .background(SSColor.background.ignoresSafeArea())
        .navigationTitle("Pain Trends")
        .navigationBarTitleDisplayMode(.inline)
        .task { await viewModel.load() }
        .refreshable { await viewModel.load() }
    }

    private var baselineCard: some View {
        VStack(alignment: .leading, spacing: SSSpacing.md) {
            Text("Your Recent Baseline")
                .ssSectionLabel()
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: SSSpacing.md) {
                baselineStat(value: viewModel.typicalPainRangeLabel, label: "Typical pain")
                baselineStat(value: viewModel.typicalSleepLabel ?? "Not synced", label: "Typical sleep")
                baselineStat(value: "\(viewModel.episodesThisMonth)", label: "Episodes this month")
                baselineStat(value: viewModel.medicationAdherenceLabel ?? "—", label: "Medication adherence")
            }
        }
        .padding(SSSpacing.lg)
        .frame(maxWidth: .infinity, alignment: .leading)
        .ssCard(padding: nil)
    }

    private func baselineStat(value: String, label: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(value)
                .font(.system(.title3, weight: .bold))
                .foregroundStyle(SSColor.textPrimary)
            Text(label)
                .ssCaption()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var patternsSection: some View {
        VStack(alignment: .leading, spacing: SSSpacing.sm) {
            Text("Patterns & Data")
                .ssSectionLabel()
            ForEach(viewModel.patterns) { pattern in
                SSInsightCard(
                    systemImage: pattern.kind == .pattern ? "chart.line.downtrend.xyaxis" : "chart.bar.doc.horizontal",
                    text: pattern.text,
                    kind: pattern.kind
                )
            }
        }
    }

    private var statsRow: some View {
        HStack(spacing: SSSpacing.sm) {
            SSMetricCard(
                systemImage: "waveform.path.ecg",
                value: viewModel.records.isEmpty ? "—" : String(format: "%.1f", viewModel.average),
                label: "Average",
                sub: "last 30 days",
                accent: SSColor.brand
            )
            SSMetricCard(
                systemImage: "arrow.up.circle.fill",
                value: viewModel.records.isEmpty ? "—" : "\(viewModel.highest)",
                label: "Highest",
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

    private var trendChart: some View {
        VStack(alignment: .leading, spacing: SSSpacing.sm) {
            Text("Trend")
                .ssSectionLabel()
            SSTrendLineChart(values: viewModel.records.map { Double($0.rating) })
                .frame(height: 120)
                .ssCard()
        }
    }

    private func summaryCard(_ insight: PainTrendInsight) -> some View {
        VStack(alignment: .leading, spacing: SSSpacing.sm) {
            Text("Summary")
                .ssSectionLabel()
            SSInsightCard(systemImage: "sparkles", text: insight.summary)
        }
    }

    private func tipsCard(_ insight: PainTrendInsight) -> some View {
        VStack(alignment: .leading, spacing: SSSpacing.sm) {
            Text("Tips")
                .ssSectionLabel()
            VStack(alignment: .leading, spacing: SSSpacing.sm) {
                ForEach(insight.tips, id: \.self) { tip in
                    HStack(alignment: .top, spacing: SSSpacing.sm) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(SSColor.success)
                        Text(tip)
                            .ssBody()
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .ssCard()
        }
    }

    private func crisisCard(_ insight: PainTrendInsight) -> some View {
        VStack(alignment: .leading, spacing: SSSpacing.sm) {
            Text("If pain escalates")
                .ssSectionLabel()
            HStack(alignment: .top, spacing: SSSpacing.sm) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundStyle(SSColor.brand)
                Text(insight.whenToSeekCare)
                    .ssBody()
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(SSSpacing.lg)
            .background(SSColor.brandSoft)
            .clipShape(RoundedRectangle(cornerRadius: SSRadius.md, style: .continuous))
        }
    }
}

#Preview {
    NavigationStack {
        InsightsView()
    }
}

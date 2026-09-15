import SwiftUI

struct TrackerView: View {
    @EnvironmentObject private var session: SessionStore
    @StateObject private var viewModel = TrackerViewModel()
    @StateObject private var voiceLogger = VoiceLogger()

    @State private var showLogForm = false
    @State private var severity: Double = 5
    @State private var selectedTriggers: Set<String> = []
    @State private var voiceLocation: String?
    @State private var showShareSheet = false
    @State private var reportURL: URL?
    private let triggers = ["Dehydration", "Cold", "Stress"]

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                GlassHeader {
                    Text("Crisis tracker")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundStyle(.white)
                }
                .frame(height: 90)

                if let errorMessage = viewModel.errorMessage, viewModel.waterIntake == nil {
                    ErrorState(message: errorMessage) {
                        Task { await viewModel.load() }
                    }
                    .padding(.top, 40)
                } else {
                    VStack(alignment: .leading, spacing: 14) {
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text("Pain trend, last 7 days")
                                    .font(.system(size: 11))
                                    .foregroundStyle(Theme.muted)
                                Spacer()
                                Button {
                                    exportReport()
                                } label: {
                                    HStack(spacing: 4) {
                                        Image(systemName: "square.and.arrow.up")
                                        Text("Export")
                                    }
                                    .font(.system(size: 10, weight: .medium))
                                    .foregroundStyle(Theme.deepRed)
                                }
                                .buttonStyle(.plain)
                                .disabled(viewModel.painRecords.isEmpty)
                            }
                            if viewModel.painRecords.count >= 2 {
                                PainTrendChart(values: viewModel.painRecords.map { Double($0.rating) })
                                    .frame(height: 56)
                            } else {
                                Text(viewModel.isLoading ? "Loading..." : "Log a few crises to see your trend")
                                    .font(.system(size: 11))
                                    .foregroundStyle(Theme.muted)
                                    .frame(height: 56)
                            }
                        }
                        .padding(14)
                        .neumorphicCard()

                        HStack(spacing: 10) {
                            StatTile(value: waterDisplay, label: "Water")
                            StatTile(value: viewModel.bloodGroup ?? "—", label: "Blood group")
                        }

                        HStack(spacing: 10) {
                            Button {
                                withAnimation { showLogForm.toggle() }
                            } label: {
                                Text("Log a crisis")
                                    .font(.system(size: 13, weight: .medium))
                                    .foregroundStyle(Theme.accent)
                                    .frame(maxWidth: .infinity)
                                    .padding(13)
                            }
                            .neumorphicPressed()

                            Button {
                                if voiceLogger.isRecording {
                                    voiceLogger.stop()
                                    applyVoiceResult()
                                } else {
                                    withAnimation { showLogForm = true }
                                    voiceLogger.start()
                                }
                            } label: {
                                Image(systemName: voiceLogger.isRecording ? "waveform" : "mic.fill")
                                    .font(.system(size: 15))
                                    .foregroundStyle(voiceLogger.isRecording ? .white : Theme.deepRed)
                                    .frame(width: 46, height: 46)
                                    .background(voiceLogger.isRecording ? AnyShapeStyle(Theme.deepRed) : AnyShapeStyle(Color.clear))
                            }
                            .neumorphicPressed(radius: 23)
                        }

                        if voiceLogger.isRecording || !voiceLogger.transcript.isEmpty {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(voiceLogger.isRecording ? "Listening..." : "Heard:")
                                    .font(.system(size: 10, weight: .medium))
                                    .foregroundStyle(Theme.deepRed)
                                Text(voiceLogger.transcript.isEmpty ? "Try \"pain 7, lower back, from the cold\"" : voiceLogger.transcript)
                                    .font(.system(size: 11))
                                    .foregroundStyle(Theme.ink)
                            }
                            .padding(10)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .neumorphicCard(radius: 12)
                        }
                        if let voiceError = voiceLogger.errorMessage {
                            Text(voiceError)
                                .font(.system(size: 11))
                                .foregroundStyle(Theme.deepRed)
                        }

                        if showLogForm {
                            VStack(alignment: .leading, spacing: 10) {
                                Text("Severity: \(Int(severity))")
                                    .font(.system(size: 11))
                                    .foregroundStyle(Theme.muted)
                                Slider(value: $severity, in: 0...10, step: 1)
                                    .tint(Theme.accent)

                                Text("Likely trigger")
                                    .font(.system(size: 11))
                                    .foregroundStyle(Theme.muted)
                                HStack(spacing: 6) {
                                    ForEach(triggers, id: \.self) { trigger in
                                        TriggerChip(
                                            title: trigger,
                                            isSelected: selectedTriggers.contains(trigger)
                                        ) {
                                            if selectedTriggers.contains(trigger) {
                                                selectedTriggers.remove(trigger)
                                            } else {
                                                selectedTriggers.insert(trigger)
                                            }
                                        }
                                    }
                                }

                                if let errorMessage = viewModel.errorMessage {
                                    Text(errorMessage)
                                        .font(.system(size: 11))
                                        .foregroundStyle(Theme.deepRed)
                                }

                                Button {
                                    Task {
                                        let saved = await viewModel.logCrisis(
                                            severity: Int(severity),
                                            triggers: Array(selectedTriggers),
                                            location: voiceLocation ?? "Crisis"
                                        )
                                        if saved {
                                            withAnimation {
                                                showLogForm = false
                                                selectedTriggers.removeAll()
                                                severity = 5
                                                voiceLocation = nil
                                                voiceLogger.transcript = ""
                                            }
                                        }
                                    }
                                } label: {
                                    HStack {
                                        if viewModel.isSaving {
                                            ProgressView().tint(Theme.background)
                                        } else {
                                            Text("Save entry")
                                        }
                                    }
                                    .font(.system(size: 12))
                                    .foregroundStyle(Theme.background)
                                    .frame(maxWidth: .infinity)
                                    .padding(10)
                                    .background(Theme.ink)
                                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                                }
                                .disabled(viewModel.isSaving)
                            }
                            .padding(14)
                            .neumorphicCard()
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
        .sheet(isPresented: $showShareSheet) {
            if let reportURL {
                ActivityView(items: [reportURL])
            }
        }
    }

    private var waterDisplay: String {
        guard let waterIntake = viewModel.waterIntake else { return "—" }
        return "\(waterIntake.amount)/\(waterIntake.target)"
    }

    private func applyVoiceResult() {
        let parsed = VoiceCrisisParser.parse(voiceLogger.transcript)
        if let rating = parsed.rating {
            severity = Double(rating)
        }
        if let location = parsed.location {
            voiceLocation = location.prefix(1).uppercased() + location.dropFirst()
        }
        for trigger in parsed.triggers where triggers.contains(trigger) {
            selectedTriggers.insert(trigger)
        }
    }

    private func exportReport() {
        let data = PainReportExporter.makePDF(
            user: session.currentUser,
            records: viewModel.painRecords,
            averageRating: viewModel.averageRating
        )
        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent("SickleShield-PainReport-\(Int(Date().timeIntervalSince1970)).pdf")
        do {
            try data.write(to: url)
            reportURL = url
            showShareSheet = true
        } catch {
            viewModel.errorMessage = "Couldn't create the PDF."
        }
    }
}

private struct TriggerChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 10))
                .foregroundStyle(Theme.ink)
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background {
                    if isSelected {
                        Color.clear.neumorphicPressed(radius: 20)
                    } else {
                        Color.clear.neumorphicCard(radius: 20)
                    }
                }
        }
        .buttonStyle(.plain)
    }
}

private struct PainTrendChart: View {
    let values: [Double]

    var body: some View {
        GeometryReader { geo in
            let maxVal = max(values.max() ?? 1, 1)
            let points = values.enumerated().map { index, value -> CGPoint in
                let x = geo.size.width * CGFloat(index) / CGFloat(values.count - 1)
                let y = geo.size.height * (1 - CGFloat(value / maxVal))
                return CGPoint(x: x, y: y)
            }
            Path { path in
                guard let first = points.first else { return }
                path.move(to: first)
                for point in points.dropFirst() {
                    path.addLine(to: point)
                }
            }
            .stroke(Theme.accent, style: StrokeStyle(lineWidth: 2.2, lineCap: .round, lineJoin: .round))
        }
    }
}

#Preview {
    TrackerView()
        .environmentObject(SessionStore())
}

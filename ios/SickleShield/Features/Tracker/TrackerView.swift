import SwiftUI

struct TrackerView: View {
    @EnvironmentObject private var session: SessionStore
    @Environment(AppRouter.self) private var router
    @StateObject private var viewModel = TrackerViewModel()
    @StateObject private var voiceLogger = VoiceLogger()

    @State private var showLogForm = false
    @State private var severity: Double = 5
    @State private var selectedTriggers: Set<String> = []
    @State private var voiceLocation: String?
    @State private var bodyLocation: String?
    @State private var selectedMedication: String?
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
                                    .foregroundStyle(SSColor.textSecondary)
                                Spacer()
                                Button {
                                    exportReport()
                                } label: {
                                    HStack(spacing: 4) {
                                        Image(systemName: "square.and.arrow.up")
                                        Text("Export")
                                    }
                                    .font(.system(size: 10, weight: .medium))
                                    .foregroundStyle(SSColor.brand)
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
                                    .foregroundStyle(SSColor.textSecondary)
                                    .frame(height: 56)
                            }
                        }
                        .padding(14)
                        .neumorphicCard()

                        if !viewModel.topTriggers.isEmpty {
                            VStack(alignment: .leading, spacing: 6) {
                                Text("Top triggers this month")
                                    .font(.system(size: 11))
                                    .foregroundStyle(SSColor.textSecondary)
                                HStack(spacing: 6) {
                                    ForEach(viewModel.topTriggers, id: \.trigger) { entry in
                                        Text("\(entry.trigger) (\(entry.count))")
                                            .font(.system(size: 10, weight: .medium))
                                            .foregroundStyle(SSColor.textPrimary)
                                            .padding(.horizontal, 10)
                                            .padding(.vertical, 5)
                                            .neumorphicCard(radius: 20)
                                    }
                                }
                            }
                            .padding(14)
                            .neumorphicCard()
                        }

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
                                    .foregroundStyle(SSColor.brand)
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
                                    .foregroundStyle(voiceLogger.isRecording ? .white : SSColor.brand)
                                    .frame(width: 46, height: 46)
                                    .background(voiceLogger.isRecording ? AnyShapeStyle(SSColor.brand) : AnyShapeStyle(Color.clear))
                            }
                            .neumorphicPressed(radius: 23)
                        }

                        if voiceLogger.isRecording || !voiceLogger.transcript.isEmpty {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(voiceLogger.isRecording ? "Listening..." : "Heard:")
                                    .font(.system(size: 10, weight: .medium))
                                    .foregroundStyle(SSColor.brand)
                                Text(voiceLogger.transcript.isEmpty ? "Try \"pain 7, lower back, from the cold\"" : voiceLogger.transcript)
                                    .font(.system(size: 11))
                                    .foregroundStyle(SSColor.textPrimary)
                            }
                            .padding(10)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .neumorphicCard(radius: 12)
                        }
                        if let voiceError = voiceLogger.errorMessage {
                            Text(voiceError)
                                .font(.system(size: 11))
                                .foregroundStyle(SSColor.brand)
                        }

                        if showLogForm {
                            VStack(alignment: .leading, spacing: 10) {
                                Text("Severity: \(Int(severity))")
                                    .font(.system(size: 11))
                                    .foregroundStyle(SSColor.textSecondary)
                                Slider(value: $severity, in: 0...10, step: 1)
                                    .tint(SSColor.brand)

                                Text("Likely trigger")
                                    .font(.system(size: 11))
                                    .foregroundStyle(SSColor.textSecondary)
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

                                Text("Where is the pain?")
                                    .font(.system(size: 11))
                                    .foregroundStyle(SSColor.textSecondary)
                                BodyMapPicker(selection: $bodyLocation)

                                Text("Took a medication for this? (optional)")
                                    .font(.system(size: 11))
                                    .foregroundStyle(SSColor.textSecondary)
                                Menu {
                                    Button("None") { selectedMedication = nil }
                                    ForEach(viewModel.reminders) { reminder in
                                        Button(reminder.medicineName) { selectedMedication = reminder.medicineName }
                                    }
                                } label: {
                                    HStack {
                                        Text(selectedMedication ?? "None")
                                            .font(.system(size: 11))
                                            .foregroundStyle(SSColor.textPrimary)
                                        Spacer()
                                        Image(systemName: "chevron.up.chevron.down")
                                            .font(.system(size: 9))
                                            .foregroundStyle(SSColor.textSecondary)
                                    }
                                    .padding(10)
                                    .neumorphicCard(radius: 12)
                                }

                                if let errorMessage = viewModel.errorMessage {
                                    Text(errorMessage)
                                        .font(.system(size: 11))
                                        .foregroundStyle(SSColor.brand)
                                }

                                Button {
                                    Task {
                                        let saved = await viewModel.logCrisis(
                                            severity: Int(severity),
                                            triggers: Array(selectedTriggers),
                                            location: bodyLocation ?? voiceLocation ?? "Crisis",
                                            medicationTaken: selectedMedication
                                        )
                                        if saved {
                                            withAnimation {
                                                showLogForm = false
                                                selectedTriggers.removeAll()
                                                severity = 5
                                                voiceLocation = nil
                                                bodyLocation = nil
                                                selectedMedication = nil
                                                voiceLogger.transcript = ""
                                            }
                                        }
                                    }
                                } label: {
                                    HStack {
                                        if viewModel.isSaving {
                                            ProgressView().tint(SSColor.background)
                                        } else {
                                            Text("Save entry")
                                        }
                                    }
                                    .font(.system(size: 12))
                                    .foregroundStyle(SSColor.background)
                                    .frame(maxWidth: .infinity)
                                    .padding(10)
                                    .background(SSColor.textPrimary)
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
        .background(SSColor.background.ignoresSafeArea())
        .task {
            await viewModel.load()
        }
        .refreshable {
            await viewModel.load()
        }
        .onChange(of: router.selectedTab) { _, tab in
            guard tab == .tracker else { return }
            Task { await viewModel.load() }
        }
        .sheet(isPresented: $showShareSheet) {
            if let reportURL {
                ActivityView(items: [reportURL])
            }
        }
        .onChange(of: router.pendingCrisisLog) { _, pending in
            guard pending else { return }
            withAnimation { showLogForm = true }
            router.pendingCrisisLog = false
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
                .foregroundStyle(SSColor.textPrimary)
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
            .stroke(SSColor.brand, style: StrokeStyle(lineWidth: 2.2, lineCap: .round, lineJoin: .round))
        }
    }
}

#Preview {
    TrackerView()
        .environmentObject(SessionStore())
        .environment(AppRouter())
}

import SwiftUI

enum QuickLogCategory: String, Identifiable, Hashable, CaseIterable {
    case pain, water, weight, mood
    var id: String { rawValue }

    var tileLabel: String {
        switch self {
        case .pain: return "Pain"
        case .water: return "Water"
        case .weight: return "Weight"
        case .mood: return "Mood"
        }
    }

    var formTitle: String {
        switch self {
        case .pain: return "How's your pain?"
        case .water: return "How many glasses?"
        case .weight: return "Today's weight (kg)"
        case .mood: return "How are you feeling?"
        }
    }

    var systemImage: String {
        switch self {
        case .pain: return "waveform.path.ecg"
        case .water: return "drop.fill"
        case .weight: return "scalemass.fill"
        case .mood: return "heart.fill"
        }
    }

    var tint: Color {
        switch self {
        case .pain: return SSColor.brand
        case .water: return SSColor.info
        case .weight: return SSColor.success
        case .mood: return SSColor.warning
        }
    }
}

/// A single page for fast, in-place logging across every category. Tapping
/// a tile reveals that category's form directly below the grid; saving
/// collapses the form and returns to the grid so a second category can be
/// logged immediately, without leaving the page.
struct QuickLogView: View {
    let onSaved: () -> Void

    @State private var selectedCategory: QuickLogCategory?
    @State private var severity: Int?
    @State private var location: String?
    @State private var selectedTriggers: Set<String> = []
    @State private var weightText = ""
    @State private var isSaving = false
    @State private var errorMessage: String?
    @State private var didSave = false
    @State private var savedMessage: String?

    private static let locations = ["Head", "Chest", "Back", "Arms", "Legs", "Joints", "Abdomen", "Other"]
    private static let triggers = ["Cold", "Heat", "Stress", "Dehydration", "Illness", "Exercise", "Unknown"]
    private static let moods: [(value: String, label: String)] = [
        ("great", "Great"), ("good", "Good"), ("okay", "Okay"), ("low", "Low"), ("struggling", "Struggling"),
    ]

    init(initialCategory: QuickLogCategory? = nil, onSaved: @escaping () -> Void) {
        self.onSaved = onSaved
        _selectedCategory = State(initialValue: initialCategory)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: SSSpacing.xl) {
                if let savedMessage {
                    Label(savedMessage, systemImage: "checkmark.circle.fill")
                        .ssSubtext(color: SSColor.success)
                        .transition(.opacity)
                }

                categoryGrid

                if let selectedCategory {
                    formSection(for: selectedCategory)
                        .transition(.opacity.combined(with: .move(edge: .top)))
                }

                if let errorMessage {
                    Text(errorMessage)
                        .ssCaption(color: SSColor.brand)
                }
            }
            .padding(SSSpacing.lg)
        }
        .background(
            ZStack {
                SSColor.background
                SSAmbientBackground()
            }
            .ignoresSafeArea()
        )
        .navigationTitle("Quick Log")
        .navigationBarTitleDisplayMode(.inline)
        .animation(.spring(response: 0.35, dampingFraction: 0.85), value: selectedCategory)
        .sensoryFeedback(trigger: didSave) { _, newValue in newValue ? .success : nil }
    }

    // MARK: - Category grid

    private var categoryGrid: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: SSSpacing.sm) {
            ForEach(QuickLogCategory.allCases) { category in
                SSQuickActionTile(
                    systemImage: category.systemImage,
                    label: category.tileLabel,
                    tint: category.tint,
                    isSelected: selectedCategory == category
                ) {
                    select(category)
                }
            }
        }
    }

    private func select(_ category: QuickLogCategory) {
        errorMessage = nil
        selectedCategory = (selectedCategory == category) ? nil : category
    }

    @ViewBuilder
    private func formSection(for category: QuickLogCategory) -> some View {
        VStack(alignment: .leading, spacing: SSSpacing.lg) {
            switch category {
            case .pain: painForm
            case .water: waterForm
            case .weight: weightForm
            case .mood: moodForm
            }
        }
        .ssCard()
    }

    private func saveSucceeded(_ category: QuickLogCategory) {
        didSave = true
        onSaved()
        savedMessage = "\(category.tileLabel) logged"
        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
            selectedCategory = nil
        }
        severity = nil
        location = nil
        selectedTriggers = []
        weightText = ""
        Task {
            try? await Task.sleep(for: .seconds(2))
            withAnimation { savedMessage = nil }
        }
    }

    // MARK: - Pain

    private var painForm: some View {
        VStack(alignment: .leading, spacing: SSSpacing.xl) {
            VStack(alignment: .leading, spacing: SSSpacing.sm) {
                Text(QuickLogCategory.pain.formTitle)
                    .ssHeadline()
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 6), spacing: SSSpacing.xs) {
                    ForEach(0...10, id: \.self) { number in
                        Button {
                            severity = number
                        } label: {
                            Text("\(number)")
                                .font(.system(.footnote, weight: .bold))
                                .frame(maxWidth: .infinity, minHeight: 36)
                                .background(severity == number ? SSColor.brand : SSColor.surfaceSecondary)
                                .foregroundStyle(severity == number ? .white : SSColor.textPrimary)
                                .clipShape(RoundedRectangle(cornerRadius: SSRadius.sm, style: .continuous))
                                .scaleEffect(severity == number ? 1.08 : 1)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .animation(.spring(response: 0.25, dampingFraction: 0.6), value: severity)
                .sensoryFeedback(.selection, trigger: severity)
            }

            VStack(alignment: .leading, spacing: SSSpacing.sm) {
                Text("Where? (optional)")
                    .ssHeadline()
                chipFlow(Self.locations, isSelected: { $0 == location }) { tapped in
                    location = (location == tapped) ? nil : tapped
                }
            }

            VStack(alignment: .leading, spacing: SSSpacing.sm) {
                Text("Possible factors? (optional)")
                    .ssHeadline()
                chipFlow(Self.triggers, isSelected: { selectedTriggers.contains($0) }) { tapped in
                    if selectedTriggers.contains(tapped) {
                        selectedTriggers.remove(tapped)
                    } else {
                        selectedTriggers.insert(tapped)
                    }
                }
            }

            Button {
                Task { await savePain() }
            } label: {
                if isSaving { ProgressView() } else { Text("Save now") }
            }
            .buttonStyle(.ssPrimary)
            .disabled(severity == nil || isSaving)
        }
    }

    private func chipFlow(_ items: [String], isSelected: @escaping (String) -> Bool, onTap: @escaping (String) -> Void) -> some View {
        FlowLayout(spacing: SSSpacing.xs) {
            ForEach(items, id: \.self) { item in
                Button {
                    onTap(item)
                } label: {
                    Text(item)
                        .font(.system(.footnote, weight: .semibold))
                        .padding(.horizontal, SSSpacing.md)
                        .padding(.vertical, SSSpacing.xs + 2)
                        .background(isSelected(item) ? SSColor.brand : SSColor.surfaceSecondary)
                        .foregroundStyle(isSelected(item) ? .white : SSColor.textPrimary)
                        .clipShape(Capsule())
                        .scaleEffect(isSelected(item) ? 1.05 : 1)
                }
                .buttonStyle(.plain)
                .animation(.spring(response: 0.25, dampingFraction: 0.6), value: isSelected(item))
            }
        }
    }

    private func savePain() async {
        guard let severity else { return }
        isSaving = true
        errorMessage = nil
        defer { isSaving = false }
        do {
            let frequency = selectedTriggers.isEmpty ? "Unspecified" : selectedTriggers.joined(separator: ", ")
            _ = try await PainAPI.createPain(
                pain: location ?? "Crisis",
                sensation: "Reported via app",
                frequency: frequency,
                rating: severity
            )
            saveSucceeded(.pain)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    // MARK: - Water

    private var waterForm: some View {
        VStack(alignment: .leading, spacing: SSSpacing.md) {
            Text(QuickLogCategory.water.formTitle)
                .ssHeadline()
            HStack(spacing: SSSpacing.sm) {
                ForEach([1, 2, 3], id: \.self) { amount in
                    Button {
                        Task { await saveWater(amount) }
                    } label: {
                        Text("+\(amount)")
                            .font(.system(.title3, weight: .bold))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, SSSpacing.lg)
                    }
                    .buttonStyle(.ssSecondary)
                    .disabled(isSaving)
                }
            }
            if isSaving {
                ProgressView().frame(maxWidth: .infinity)
            }
        }
    }

    private func saveWater(_ amount: Int) async {
        isSaving = true
        errorMessage = nil
        defer { isSaving = false }
        do {
            let before = try? await GoalAPI.waterIntake()
            try await GoalAPI.logWaterIntake(amount: amount)
            let after = try await GoalAPI.waterIntake()
            if after.target > 0, (before?.amount ?? 0) < after.target, after.amount >= after.target {
                try? await NotificationAPI.create(title: "Goal reached!", body: "You hit your water intake goal for today.")
            }
            LocalNotificationScheduler.syncWaterReminders(amount: after.amount, target: after.target)
            saveSucceeded(.water)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    // MARK: - Weight

    private var weightForm: some View {
        VStack(alignment: .leading, spacing: SSSpacing.md) {
            Text(QuickLogCategory.weight.formTitle)
                .ssHeadline()
            TextField("e.g. 72.5", text: $weightText)
                .keyboardType(.decimalPad)
                .font(.system(.title2, weight: .semibold))
                .padding(SSSpacing.md)
                .background(SSColor.surfaceSecondary)
                .clipShape(RoundedRectangle(cornerRadius: SSRadius.md, style: .continuous))
            Button {
                Task { await saveWeight() }
            } label: {
                if isSaving { ProgressView() } else { Text("Save now") }
            }
            .buttonStyle(.ssPrimary)
            .disabled(Double(weightText) == nil || isSaving)

            NavigationLink("Set or edit a weight goal") {
                WeightView()
            }
            .font(.system(.footnote, weight: .semibold))
            .foregroundStyle(SSColor.brand)
        }
    }

    private func saveWeight() async {
        guard let weight = Double(weightText) else { return }
        isSaving = true
        errorMessage = nil
        defer { isSaving = false }
        do {
            _ = try await GoalAPI.logWeight(weight)
            saveSucceeded(.weight)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    // MARK: - Mood

    private var moodForm: some View {
        VStack(alignment: .leading, spacing: SSSpacing.md) {
            Text(QuickLogCategory.mood.formTitle)
                .ssHeadline()
            VStack(spacing: SSSpacing.sm) {
                ForEach(Self.moods, id: \.value) { mood in
                    Button {
                        Task { await saveMood(mood.value) }
                    } label: {
                        Text(mood.label)
                            .font(.system(.body, weight: .semibold))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, SSSpacing.md)
                    }
                    .buttonStyle(.ssSecondary)
                    .disabled(isSaving)
                }
            }
            if isSaving {
                ProgressView().frame(maxWidth: .infinity)
            }
        }
    }

    private func saveMood(_ value: String) async {
        isSaving = true
        errorMessage = nil
        defer { isSaving = false }
        do {
            _ = try await MoodAPI.log(mood: value)
            saveSucceeded(.mood)
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}

/// A minimal flow layout for wrapping chip rows - SwiftUI has no built-in
/// equivalent to a wrapping HStack.
private struct FlowLayout: Layout {
    var spacing: CGFloat

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let maxWidth = proposal.width ?? .infinity
        var rowWidth: CGFloat = 0
        var totalHeight: CGFloat = 0
        var rowHeight: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if rowWidth + size.width > maxWidth, rowWidth > 0 {
                totalHeight += rowHeight + spacing
                rowWidth = 0
                rowHeight = 0
            }
            rowWidth += size.width + spacing
            rowHeight = max(rowHeight, size.height)
        }
        totalHeight += rowHeight
        return CGSize(width: maxWidth, height: totalHeight)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        var x = bounds.minX
        var y = bounds.minY
        var rowHeight: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if x + size.width > bounds.maxX, x > bounds.minX {
                x = bounds.minX
                y += rowHeight + spacing
                rowHeight = 0
            }
            subview.place(at: CGPoint(x: x, y: y), anchor: .topLeading, proposal: .unspecified)
            x += size.width + spacing
            rowHeight = max(rowHeight, size.height)
        }
    }
}

#Preview {
    NavigationStack {
        QuickLogView(initialCategory: .pain) {}
    }
}

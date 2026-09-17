import SwiftUI

struct WaterIntakeView: View {
    @State private var viewModel = WaterIntakeViewModel()
    @State private var dragAmount: Int?
    @State private var showCelebration = false

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                if viewModel.status != nil {
                    dial
                        .padding(.top, 24)
                    Text("Drag the ring to log how many glasses you've had")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                } else if viewModel.isLoading {
                    ProgressView()
                        .padding(.top, 60)
                }

                if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                        .font(.footnote)
                        .foregroundStyle(.red)
                }
            }
            .padding()
            .frame(maxWidth: .infinity)
        }
        .navigationTitle("Water intake")
        .task { await viewModel.load() }
        .refreshable { await viewModel.load() }
        .onChange(of: viewModel.status?.amount) { oldValue, newValue in
            guard let newValue, let target = viewModel.status?.target, target > 0 else { return }
            if (oldValue ?? 0) < target && newValue >= target {
                showCelebration = true
            }
        }
        .sensoryFeedback(trigger: showCelebration) { _, newValue in
            newValue ? .success : nil
        }
        .overlay {
            if showCelebration {
                CelebrationOverlay { showCelebration = false }
                    .transition(.opacity.combined(with: .scale(scale: 0.9)))
            }
        }
        .animation(.spring(response: 0.35, dampingFraction: 1), value: showCelebration)
    }

    private var dial: some View {
        let target = max(viewModel.status?.target ?? 10, 1)
        let confirmed = viewModel.status?.amount ?? 0
        let displayed = dragAmount ?? confirmed

        return GeometryReader { geo in
            let size = min(geo.size.width, geo.size.height)
            ZStack {
                Circle()
                    .stroke(Color(uiColor: .systemGray5), lineWidth: 14)
                Circle()
                    .trim(from: 0, to: CGFloat(displayed) / CGFloat(target))
                    .stroke(Theme.accent, style: StrokeStyle(lineWidth: 14, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                Circle()
                    .fill(Theme.accent)
                    .frame(width: 26, height: 26)
                    .offset(x: size / 2 - 7)
                    .rotationEffect(.degrees(360 * Double(displayed) / Double(target)))
                    .shadow(radius: 2)
                VStack(spacing: 4) {
                    Text("\(displayed)")
                        .font(.system(size: 40, weight: .bold))
                        .contentTransition(.numericText())
                    Text("of \(target) glasses")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .frame(width: size, height: size)
            .position(x: geo.size.width / 2, y: geo.size.height / 2)
            .contentShape(Circle())
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        let center = CGPoint(x: geo.size.width / 2, y: geo.size.height / 2)
                        let dx = value.location.x - center.x
                        let dy = value.location.y - center.y
                        var degrees = atan2(dy, dx) * 180 / .pi + 90
                        if degrees < 0 { degrees += 360 }
                        let fraction = degrees / 360
                        let rawAmount = Int((fraction * Double(target)).rounded())
                        dragAmount = min(max(rawAmount, confirmed), target)
                    }
                    .onEnded { _ in
                        if let dragAmount, dragAmount > confirmed {
                            Task { await viewModel.logGlasses(dragAmount - confirmed) }
                        }
                        dragAmount = nil
                    }
            )
        }
        .frame(width: 220, height: 220)
        .animation(.spring(response: 0.3, dampingFraction: 1), value: dragAmount)
    }
}

private struct CelebrationOverlay: View {
    let onDismiss: () -> Void

    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 56))
                .foregroundStyle(.green)
            Text("Goal reached!")
                .font(.title3.weight(.semibold))
            Text("You've hit your water intake goal for today.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            Button("Nice", action: onDismiss)
                .buttonStyle(.borderedProminent)
                .padding(.top, 4)
        }
        .padding(28)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
        .padding(40)
        .task {
            try? await Task.sleep(for: .seconds(3))
            onDismiss()
        }
    }
}

#Preview {
    NavigationStack {
        WaterIntakeView()
    }
}

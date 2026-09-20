import SwiftUI

struct WaterIntakeView: View {
    @State private var viewModel = WaterIntakeViewModel()
    @State private var dragAmount: Int?
    @State private var dragStartAngle: Double?
    @State private var dragStartAmount: Int = 0
    @State private var showCelebration = false

    var body: some View {
        ScrollView {
            VStack(spacing: SSSpacing.xxl) {
                if viewModel.status != nil {
                    dial
                        .padding(.top, SSSpacing.xl)
                    statusLine
                    Text("Drag the ring to log how many glasses you've had")
                        .ssCaption()
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, SSSpacing.xxl)
                } else if viewModel.isLoading {
                    ProgressView()
                        .padding(.top, 60)
                }

                if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                        .ssCaption(color: SSColor.brand)
                }
            }
            .padding(SSSpacing.lg)
            .frame(maxWidth: .infinity)
        }
        .background(
            ZStack {
                SSColor.background
                SSAmbientBackground()
            }
            .ignoresSafeArea()
        )
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

    // MARK: - Dial

    /// A drag anywhere on the ring rotates the thumb relative to *where the
    /// gesture started*, not to the finger's raw absolute angle - tracking
    /// absolute angle caused the displayed number to lag/mismatch the finger
    /// during a live drag (an implicit `.animation` retriggering on every
    /// frame) and created a dead zone below the already-confirmed amount.
    private var dial: some View {
        let target = max(viewModel.status?.target ?? 10, 1)
        let confirmed = viewModel.status?.amount ?? 0
        let displayed = dragAmount ?? confirmed
        let goalMet = confirmed >= target
        let ringColor = goalMet ? SSColor.success : SSColor.brand

        return GeometryReader { geo in
            let size = min(geo.size.width, geo.size.height)
            ZStack {
                Circle()
                    .stroke(SSColor.surfaceSecondary, lineWidth: 14)
                Circle()
                    .trim(from: 0, to: CGFloat(displayed) / CGFloat(target))
                    .stroke(ringColor, style: StrokeStyle(lineWidth: 14, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                Circle()
                    .fill(ringColor)
                    .frame(width: 26, height: 26)
                    .offset(x: size / 2 - 7)
                    .rotationEffect(.degrees(360 * Double(displayed) / Double(target) - 90))
                    .shadow(radius: 2)
                VStack(spacing: 4) {
                    Text("\(displayed)")
                        .ssDisplay()
                        .contentTransition(.numericText())
                    Text("of \(target) glasses")
                        .ssCaption()
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
                        var angle = atan2(dy, dx) * 180 / .pi + 90
                        if angle < 0 { angle += 360 }

                        if dragStartAngle == nil {
                            dragStartAngle = angle
                            dragStartAmount = confirmed
                        }

                        var delta = angle - (dragStartAngle ?? angle)
                        if delta > 180 { delta -= 360 }
                        if delta < -180 { delta += 360 }

                        let amountDelta = delta / 360 * Double(target)
                        let rawAmount = Int((Double(dragStartAmount) + amountDelta).rounded())
                        dragAmount = min(max(rawAmount, confirmed), target)
                    }
                    .onEnded { _ in
                        dragStartAngle = nil
                        let finalAmount = dragAmount
                        if let finalAmount, finalAmount > confirmed {
                            Task {
                                await viewModel.logGlasses(finalAmount - confirmed)
                                withAnimation(.spring(response: 0.3, dampingFraction: 1)) {
                                    dragAmount = nil
                                }
                            }
                        } else {
                            withAnimation(.spring(response: 0.3, dampingFraction: 1)) {
                                dragAmount = nil
                            }
                        }
                    }
            )
        }
        .frame(width: 220, height: 220)
    }

    private var statusLine: some View {
        let target = max(viewModel.status?.target ?? 10, 1)
        let confirmed = viewModel.status?.amount ?? 0
        let remaining = target - confirmed
        let goalMet = confirmed >= target

        return Group {
            if goalMet {
                Label("Goal reached, nice work!", systemImage: "checkmark.circle.fill")
                    .ssSubtext(color: SSColor.success)
            } else {
                Text("💧 \(remaining) more to reach today's goal")
                    .ssSubtext()
            }
        }
        .animation(.spring(response: 0.3, dampingFraction: 1), value: goalMet)
    }
}

private struct CelebrationOverlay: View {
    let onDismiss: () -> Void
    @State private var appeared = false

    var body: some View {
        VStack(spacing: SSSpacing.md) {
            Text("🎉")
                .font(.system(size: 56))
                .scaleEffect(appeared ? 1 : 0.5)
            Text("Goal reached!")
                .ssTitle()
            Text("You've hit your water intake goal for today.")
                .ssSubtext()
                .multilineTextAlignment(.center)
            Button("Nice", action: onDismiss)
                .buttonStyle(.ssPrimary)
                .padding(.top, SSSpacing.xs)
        }
        .padding(SSSpacing.xxl)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: SSRadius.lg, style: .continuous))
        .padding(SSSpacing.xxxl)
        .onAppear {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
                appeared = true
            }
        }
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

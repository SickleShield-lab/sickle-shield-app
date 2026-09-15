import SwiftUI

struct PulsingSOSButton: View {
    var action: () -> Void
    @State private var animate = false

    var body: some View {
        Button(action: action) {
            ZStack {
                ForEach(0..<2, id: \.self) { i in
                    Circle()
                        .fill(Theme.deepRed.opacity(0.35))
                        .scaleEffect(animate ? 1.8 : 1)
                        .opacity(animate ? 0 : 0.55)
                        .animation(
                            .easeOut(duration: 1.8)
                                .repeatForever(autoreverses: false)
                                .delay(Double(i) * 0.6),
                            value: animate
                        )
                }

                Circle()
                    .fill(Theme.cardBackground)
                    .frame(width: 120, height: 120)
                    .shadow(color: .black.opacity(0.14), radius: 8, x: 5, y: 5)
                    .shadow(color: .white.opacity(0.85), radius: 8, x: -5, y: -5)
                    .overlay(
                        VStack(spacing: 4) {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .font(.system(size: 26))
                            Text("SOS")
                                .font(.system(size: 13, weight: .medium))
                        }
                        .foregroundStyle(Theme.deepRed)
                    )
            }
            .frame(width: 120, height: 120)
        }
        .buttonStyle(.plain)
        .onAppear { animate = true }
    }
}

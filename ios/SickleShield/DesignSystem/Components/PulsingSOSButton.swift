import SwiftUI

struct PulsingSOSButton: View {
    var action: () -> Void
    @State private var animate = false
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        Button(action: action) {
            ZStack {
                ForEach(0..<2, id: \.self) { i in
                    Circle()
                        .fill(SSColor.brand.opacity(0.35))
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
                    .fill(SSColor.surface)
                    .frame(width: 120, height: 120)
                    .shadow(color: .black.opacity(colorScheme == .dark ? 0.6 : 0.14), radius: 8, x: 5, y: 5)
                    .shadow(color: .white.opacity(colorScheme == .dark ? 0.06 : 0.85), radius: 8, x: -5, y: -5)
                    .overlay(
                        VStack(spacing: 4) {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .font(.system(size: 26))
                            Text("SOS")
                                .font(.system(size: 13, weight: .medium))
                        }
                        .foregroundStyle(SSColor.brand)
                    )
            }
            .frame(width: 120, height: 120)
        }
        .buttonStyle(.plain)
        .onAppear { animate = true }
    }
}

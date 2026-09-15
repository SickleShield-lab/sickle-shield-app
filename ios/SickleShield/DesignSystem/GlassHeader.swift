import SwiftUI

struct GlassHeader<Content: View>: View {
    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        ZStack {
            Theme.background

            Circle()
                .fill(Theme.deepRed.opacity(0.6))
                .frame(width: 130, height: 130)
                .blur(radius: 18)
                .offset(x: 100, y: -70)

            Circle()
                .fill(Theme.deepRedDark.opacity(0.5))
                .frame(width: 100, height: 100)
                .blur(radius: 18)
                .offset(x: -110, y: -20)

            VStack(alignment: .leading, spacing: 8) {
                content
            }
            .padding(14)
            .background(.ultraThinMaterial)
            .background(Theme.deepRed.opacity(0.35))
            .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .stroke(Color.white.opacity(0.3), lineWidth: 1)
            )
            .padding(.horizontal, 16)
        }
        .clipShape(
            UnevenRoundedRectangle(
                topLeadingRadius: 0,
                bottomLeadingRadius: 30,
                bottomTrailingRadius: 30,
                topTrailingRadius: 0,
                style: .continuous
            )
        )
    }
}

import SwiftUI

private struct OnboardingSlide: Identifiable {
    let id = UUID()
    let systemImage: String
    let title: String
    let subtitle: String
}

struct OnboardingView: View {
    let onFinish: () -> Void

    @State private var selection = 0

    private let slides = [
        OnboardingSlide(
            systemImage: "waveform.path.ecg",
            title: "Track every crisis",
            subtitle: "Log pain, triggers, and severity in seconds, and see your trends over time."
        ),
        OnboardingSlide(
            systemImage: "phone.fill",
            title: "Help, fast",
            subtitle: "One tap sends your location and recent vitals to your emergency contacts."
        ),
        OnboardingSlide(
            systemImage: "pills.fill",
            title: "Everything in one place",
            subtitle: "Medications, appointments, hydration, and weight goals, all in Sickle Shield."
        ),
    ]

    var body: some View {
        VStack {
            TabView(selection: $selection) {
                ForEach(Array(slides.enumerated()), id: \.element.id) { index, slide in
                    VStack(spacing: 20) {
                        Image(systemName: slide.systemImage)
                            .font(.system(size: 64))
                            .foregroundStyle(SSColor.brand)
                        Text(slide.title)
                            .font(.system(size: 22, weight: .semibold))
                            .foregroundStyle(SSColor.textPrimary)
                        Text(slide.subtitle)
                            .font(.system(size: 14))
                            .foregroundStyle(SSColor.textSecondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 32)
                    }
                    .tag(index)
                }
            }
            .tabViewStyle(.page)
            .indexViewStyle(.page(backgroundDisplayMode: .always))

            Button {
                if selection < slides.count - 1 {
                    withAnimation { selection += 1 }
                } else {
                    onFinish()
                }
            } label: {
                Text(selection < slides.count - 1 ? "Next" : "Get started")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(SSColor.brand)
                    .frame(maxWidth: .infinity)
                    .padding(13)
            }
            .neumorphicPressed()
            .padding(.horizontal, 20)

            Button("Skip", action: onFinish)
                .font(.system(size: 12))
                .foregroundStyle(SSColor.textSecondary)
                .padding(.vertical, 16)
        }
        .background(SSColor.background.ignoresSafeArea())
    }
}

#Preview {
    OnboardingView(onFinish: {})
}

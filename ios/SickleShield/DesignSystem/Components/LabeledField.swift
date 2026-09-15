import SwiftUI

struct LabeledField<Content: View>: View {
    let label: String
    let content: Content

    init(label: String, @ViewBuilder content: () -> Content) {
        self.label = label
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label)
                .font(.system(size: 11))
                .foregroundStyle(Theme.muted)
            content
                .font(.system(size: 14))
                .foregroundStyle(Theme.ink)
                .padding(12)
                .neumorphicCard(radius: 12)
        }
    }
}

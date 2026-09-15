import SwiftUI

struct StatTile: View {
    let value: String
    let label: String
    var accent: Color = Theme.ink

    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.system(size: 17, weight: .medium))
                .foregroundStyle(accent)
            Text(label)
                .font(.system(size: 9))
                .foregroundStyle(Theme.muted)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .neumorphicCard()
    }
}

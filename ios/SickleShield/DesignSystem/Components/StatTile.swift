import SwiftUI

struct StatTile: View {
    let value: String
    let label: String
    var accent: Color = SSColor.textPrimary

    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.system(size: 17, weight: .medium))
                .foregroundStyle(accent)
            Text(label)
                .font(.system(size: 9))
                .foregroundStyle(SSColor.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .neumorphicCard()
    }
}

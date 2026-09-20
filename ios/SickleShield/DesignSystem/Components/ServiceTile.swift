import SwiftUI

struct ServiceTile: View {
    let icon: String
    let label: String
    var action: () -> Void = {}

    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 18))
                    .foregroundStyle(SSColor.brand)
                Text(label)
                    .font(.system(size: 10))
                    .foregroundStyle(SSColor.textPrimary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .neumorphicCard()
        }
        .buttonStyle(.plain)
    }
}

import SwiftUI

/// A small colored rounded-square icon + title, matching the row style used
/// throughout iOS's own Settings app. Use as the `label` of a
/// `NavigationLink` or `Button` in a Settings `List`.
struct SettingsIconLabel: View {
    let systemImage: String
    let tint: Color
    let title: String

    var body: some View {
        Label {
            Text(title)
        } icon: {
            RoundedRectangle(cornerRadius: 7, style: .continuous)
                .fill(tint)
                .frame(width: 28, height: 28)
                .overlay {
                    Image(systemName: systemImage)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(.white)
                }
        }
    }
}

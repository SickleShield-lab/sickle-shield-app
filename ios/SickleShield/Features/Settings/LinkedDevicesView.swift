import SwiftUI

/// Placeholder for a future watchOS companion app - no pairing flow exists
/// yet, this just sets expectations rather than showing a dead-end blank
/// screen.
struct LinkedDevicesView: View {
    var body: some View {
        List {
            Section {
                VStack(spacing: SSSpacing.md) {
                    Image(systemName: "applewatch")
                        .font(.system(size: 40))
                        .foregroundStyle(SSColor.textSecondary)
                    Text("No linked devices yet")
                        .ssHeadline()
                    Text("Apple Watch support is planned for a future update. When it's available, you'll be able to pair your watch here.")
                        .ssCaption()
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, SSSpacing.xl)
            }
            .listRowBackground(Color.clear)
        }
        .navigationTitle("Linked Devices")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        LinkedDevicesView()
    }
}

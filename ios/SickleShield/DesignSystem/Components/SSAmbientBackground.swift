import SwiftUI

/// Two soft, static blurred color blobs sitting behind content - the ambient
/// depth treatment already used by `GlassHeader`, ported onto the semantic
/// `SSColor` system for full-screen use behind a `ScrollView` rather than
/// just a header card. Meant to sit directly on top of `SSColor.background`.
struct SSAmbientBackground: View {
    var primary: Color = SSColor.brandSoft
    var secondary: Color = SSColor.info

    var body: some View {
        ZStack {
            Circle()
                .fill(primary.opacity(0.6))
                .frame(width: 220, height: 220)
                .blur(radius: 50)
                .offset(x: 120, y: -190)
            Circle()
                .fill(secondary.opacity(0.22))
                .frame(width: 180, height: 180)
                .blur(radius: 50)
                .offset(x: -130, y: 240)
        }
    }
}

#Preview {
    ZStack {
        SSColor.background
        SSAmbientBackground()
    }
    .ignoresSafeArea()
}

import SwiftUI

enum Theme {
    static let background = Color(hex: "E7E7EA")
    static let cardBackground = Color(hex: "E7E7EA")
    static let ink = Color(hex: "3A3A3E")
    static let muted = Color(hex: "8A8A90")
    static let accent = Color(hex: "D3573F")
    static let deepRed = Color(hex: "8C0F26")
    static let deepRedDark = Color(hex: "5C0B1A")

    static let cardRadius: CGFloat = 18
    static let pillRadius: CGFloat = 16
}

extension Color {
    init(hex: String) {
        let scanner = Scanner(string: hex)
        var rgb: UInt64 = 0
        scanner.scanHexInt64(&rgb)
        let r = Double((rgb & 0xFF0000) >> 16) / 255
        let g = Double((rgb & 0x00FF00) >> 8) / 255
        let b = Double(rgb & 0x0000FF) / 255
        self.init(red: r, green: g, blue: b)
    }
}

import Foundation

/// Bridges data between the main app and the widget extension via an App
/// Group. Widgets can't make authenticated API calls themselves (limited
/// execution budget, no easy Keychain sharing setup here), so the app writes
/// its latest fetched values here whenever it loads, and the widget just
/// reads what was last written.
enum SharedStore {
    static let appGroupID = "group.com.sickleshield.app"

    private static var defaults: UserDefaults? {
        UserDefaults(suiteName: appGroupID)
    }

    static func writeWidgetSnapshot(painScore: Double, water: String, updatedAt: Date) {
        defaults?.set(painScore, forKey: "painScore")
        defaults?.set(water, forKey: "water")
        defaults?.set(updatedAt, forKey: "updatedAt")
    }

    static func readWidgetSnapshot() -> (painScore: Double, water: String, updatedAt: Date?) {
        let painScore = defaults?.double(forKey: "painScore") ?? 0
        let water = defaults?.string(forKey: "water") ?? "-/-"
        let updatedAt = defaults?.object(forKey: "updatedAt") as? Date
        return (painScore, water, updatedAt)
    }
}

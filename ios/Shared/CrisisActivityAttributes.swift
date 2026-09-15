import ActivityKit

/// Shared between the main app (which starts/updates/ends the activity) and
/// the widget extension (which renders it on the Lock Screen / Dynamic
/// Island) - both targets include this same file.
struct CrisisActivityAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        var severity: Int
        var startedAt: Date
    }

    var contactName: String
}

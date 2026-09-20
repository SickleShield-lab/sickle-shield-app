import Foundation

struct ImportantUpdate: Identifiable {
    let id: String
    let title: String
    let body: String
}

/// Local-only "what's new" content. There is no backend broadcast/
/// announcement model in this app, so this can't yet be pushed by an admin
/// after release - it's a static list bundled with the app, structured so a
/// real backend-driven feed can slot in later without changing the UI.
enum ImportantUpdates {
    static let all: [ImportantUpdate] = [
        ImportantUpdate(
            id: "crisis-mode-launch",
            title: "Crisis Mode is here",
            body: "Start Crisis Mode from the Emergency tab for a calm, guided screen with your Pain Plan, Medical ID, and one-tap calls during a crisis."
        ),
    ]
}

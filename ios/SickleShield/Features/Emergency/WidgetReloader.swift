import WidgetKit
import ActivityKit

enum WidgetReloader {
    static func reloadAll() {
        WidgetCenter.shared.reloadAllTimelines()
    }
}

/// Starts/updates/ends the Lock Screen & Dynamic Island Live Activity for an
/// active crisis. The widget extension target owns the actual UI
/// (SickleShieldWidgets/CrisisLiveActivity.swift) - this just drives it.
@available(iOS 16.1, *)
enum CrisisLiveActivityController {
    static func start(severity: Int, contactName: String) {
        guard ActivityAuthorizationInfo().areActivitiesEnabled else { return }
        let attributes = CrisisActivityAttributes(contactName: contactName)
        let state = CrisisActivityAttributes.ContentState(severity: severity, startedAt: Date())
        do {
            _ = try Activity.request(attributes: attributes, content: .init(state: state, staleDate: nil))
        } catch {
            // Live Activities are a nice-to-have here; a failure to start one
            // must never block the actual SOS/crisis flow.
        }
    }

    static func endAll() {
        Task {
            for activity in Activity<CrisisActivityAttributes>.activities {
                await activity.end(nil, dismissalPolicy: .immediate)
            }
        }
    }
}

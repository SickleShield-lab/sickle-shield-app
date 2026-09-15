import WidgetKit
import SwiftUI
import ActivityKit

@available(iOS 16.1, *)
struct CrisisLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: CrisisActivityAttributes.self) { context in
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Active crisis")
                        .font(.system(size: 12, weight: .semibold))
                    Text("Severity \(context.state.severity)/10")
                        .font(.system(size: 11))
                        .foregroundStyle(.secondary)
                }
                Spacer()
                Text(context.attributes.contactName)
                    .font(.system(size: 11))
                    .foregroundStyle(.secondary)
            }
            .padding()
            .activityBackgroundTint(Color(red: 0.55, green: 0.05, blue: 0.15))
            .activitySystemActionForegroundColor(.white)
        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    Text("Crisis")
                        .font(.system(size: 12, weight: .semibold))
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text("\(context.state.severity)/10")
                        .font(.system(size: 12, weight: .semibold))
                }
                DynamicIslandExpandedRegion(.bottom) {
                    Text("Alerted \(context.attributes.contactName)")
                        .font(.system(size: 11))
                        .foregroundStyle(.secondary)
                }
            } compactLeading: {
                Image(systemName: "exclamationmark.triangle.fill")
            } compactTrailing: {
                Text("\(context.state.severity)")
            } minimal: {
                Image(systemName: "exclamationmark.triangle.fill")
            }
        }
    }
}

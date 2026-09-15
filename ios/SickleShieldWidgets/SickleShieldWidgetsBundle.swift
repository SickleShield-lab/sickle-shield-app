import WidgetKit
import SwiftUI

@main
struct SickleShieldWidgetsBundle: WidgetBundle {
    var body: some Widget {
        PainWidget()
        if #available(iOS 16.1, *) {
            CrisisLiveActivity()
        }
    }
}

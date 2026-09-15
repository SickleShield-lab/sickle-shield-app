import UIKit

enum DeviceIdentifier {
    /// The backend requires a non-empty `fcmToken` on signup/login for push
    /// notifications. Real push delivery needs Firebase Cloud Messaging wired
    /// up (a GoogleService-Info.plist + APNs setup) which hasn't happened yet.
    /// Until then, this sends the device's own vendor-scoped UUID so the field
    /// is a real, stable per-install identifier rather than a fake string -
    /// but push notifications will not actually be delivered until FCM is
    /// integrated and this is replaced with a real messaging token.
    static var placeholderFCMToken: String {
        UIDevice.current.identifierForVendor?.uuidString ?? "unknown-device-\(UUID().uuidString)"
    }
}

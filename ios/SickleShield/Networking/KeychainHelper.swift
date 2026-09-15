import Foundation
import Security

/// Minimal Keychain wrapper for storing the JWT. Storing it in the Keychain
/// (rather than UserDefaults) keeps it out of plain-text app storage.
final class KeychainHelper {
    static let shared = KeychainHelper()
    private init() {}

    private let service = "com.sickleshield.app"
    private let account = "authToken"

    var token: String? {
        get {
            var query: [String: Any] = [
                kSecClass as String: kSecClassGenericPassword,
                kSecAttrService as String: service,
                kSecAttrAccount as String: account,
                kSecReturnData as String: true,
                kSecMatchLimit as String: kSecMatchLimitOne
            ]
            var result: AnyObject?
            let status = SecItemCopyMatching(query as CFDictionary, &result)
            guard status == errSecSuccess, let data = result as? Data else { return nil }
            return String(data: data, encoding: .utf8)
        }
        set {
            let query: [String: Any] = [
                kSecClass as String: kSecClassGenericPassword,
                kSecAttrService as String: service,
                kSecAttrAccount as String: account
            ]
            SecItemDelete(query as CFDictionary)

            guard let newValue, let data = newValue.data(using: .utf8) else { return }
            var attributes = query
            attributes[kSecValueData as String] = data
            SecItemAdd(attributes as CFDictionary, nil)
        }
    }

    func clear() {
        token = nil
    }
}

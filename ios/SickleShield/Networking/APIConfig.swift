import Foundation

enum APIConfig {
    // Point this at your deployed backend (e.g. a Vercel URL), or
    // "http://localhost:5006/api/v1" when running the backend locally
    // and testing in the iOS Simulator (the simulator shares the Mac's
    // localhost, so this works with no extra setup). A physical device
    // needs your Mac's LAN IP instead, e.g. "http://192.168.1.23:5006/api/v1".
    static let baseURL = URL(string: "http://localhost:5006/api/v1")!
}

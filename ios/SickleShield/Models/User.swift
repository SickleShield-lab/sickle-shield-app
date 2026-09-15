import Foundation

struct User: Codable, Identifiable {
    let id: String
    let username: String
    let email: String
    var fcmToken: String?
    var profileImage: String?
    var lang: String?
    var dob: String?
    var gender: String?
    var smoking: Bool?
    var diagnosis: String?
    var weight: String?
    var bloodGroup: String?
    var painManager: Int?
    var waterIntake: Int?
    var mobileNumber: String?
    var role: String?
    /// Only present on GET /auth/profile - today's logged water intake amount.
    var lastIntake: Int?
}

struct LoginResponse: Codable {
    let accessToken: String
    let userInfo: User
}

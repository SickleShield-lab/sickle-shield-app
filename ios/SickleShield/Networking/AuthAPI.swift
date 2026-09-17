import Foundation

enum AuthAPI {
    struct SignUpRequest: Encodable {
        let username: String
        let email: String
        let password: String
        let fcmToken: String
    }

    struct SignUpVerificationRequest: Encodable {
        let email: String
        let otp: String
    }

    struct SignUpVerificationResponse: Codable {
        let accessToken: String
        let user: User
    }

    struct LoginRequest: Encodable {
        let email: String
        let password: String
        let fcmToken: String
    }

    struct UpdateProfileRequest: Encodable {
        var mobileNumber: String?
        var lang: String?
        var gender: String?
        var smoking: Bool?
        var diagnosis: String?
        var weight: String?
        var bloodGroup: String?
        var waterIntake: Int?
    }

    static func signUp(username: String, email: String, password: String) async throws {
        let body = SignUpRequest(
            username: username,
            email: email,
            password: password,
            fcmToken: DeviceIdentifier.placeholderFCMToken
        )
        try await APIClient.shared.requestVoid("users/create", method: "POST", body: body)
    }

    static func verifySignUp(email: String, otp: String) async throws -> SignUpVerificationResponse {
        let body = SignUpVerificationRequest(email: email, otp: otp)
        return try await APIClient.shared.request("users/signup-verification", method: "POST", body: body)
    }

    static func login(email: String, password: String) async throws -> LoginResponse {
        let body = LoginRequest(
            email: email,
            password: password,
            fcmToken: DeviceIdentifier.placeholderFCMToken
        )
        return try await APIClient.shared.request("auth/login", method: "POST", body: body)
    }

    static func fetchProfile() async throws -> User {
        try await APIClient.shared.request("auth/profile", method: "GET")
    }

    static func updateProfile(_ payload: UpdateProfileRequest) async throws -> User {
        try await APIClient.shared.request("auth/profile", method: "PATCH", body: payload)
    }

    // MARK: - Forgot password

    struct EmailRequest: Encodable {
        let email: String
    }

    struct VerifyOtpRequest: Encodable {
        let email: String
        let otp: String
    }

    struct VerifyOtpResponse: Decodable {
        let accessToken: String
    }

    struct ResetPasswordRequest: Encodable {
        let newPassword: String
    }

    static func sendForgotPasswordOtp(email: String) async throws {
        try await APIClient.shared.requestVoid("auth/send-otp", method: "POST", body: EmailRequest(email: email))
    }

    /// Returns a short-lived token; pass it as `tempToken` to `resetPassword`.
    static func verifyForgotPasswordOtp(email: String, otp: String) async throws -> String {
        let response: VerifyOtpResponse = try await APIClient.shared.request(
            "auth/verify-otp", method: "POST", body: VerifyOtpRequest(email: email, otp: otp)
        )
        return response.accessToken
    }

    static func resetPassword(newPassword: String, tempToken: String) async throws {
        try await APIClient.shared.requestVoid(
            "auth/reset-password", method: "PATCH", body: ResetPasswordRequest(newPassword: newPassword), overrideToken: tempToken
        )
    }
}

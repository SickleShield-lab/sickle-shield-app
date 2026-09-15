import Foundation

/// Matches the backend's shared/sendResponse.ts shape: { success, message, meta, data }.
struct APIEnvelope<T: Decodable>: Decodable {
    let success: Bool
    let message: String
    let data: T?
}

/// Matches globalErrorHandler.ts's error response shape.
struct APIErrorEnvelope: Decodable {
    let success: Bool
    let message: String
}

/// Used where an endpoint's `data` is null or irrelevant (e.g. deletes).
struct EmptyData: Decodable {}

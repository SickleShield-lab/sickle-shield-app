import Foundation

enum APIError: LocalizedError {
    case invalidResponse
    case server(message: String, statusCode: Int)
    case decoding(Error)
    case unauthorized
    case unknown(Error)

    var errorDescription: String? {
        switch self {
        case .invalidResponse:
            return "The server sent an unexpected response."
        case .server(let message, _):
            return message
        case .decoding:
            return "Couldn't understand the server's response."
        case .unauthorized:
            return "Your session has expired. Please log in again."
        case .unknown(let error):
            return error.localizedDescription
        }
    }
}

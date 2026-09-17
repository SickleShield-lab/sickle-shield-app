import Foundation

final class APIClient {
    static let shared = APIClient()
    private init() {}

    private let decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }()

    private let encoder: JSONEncoder = {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        return encoder
    }()

    // MARK: - JSON requests

    func request<T: Decodable>(
        _ path: String,
        method: String = "GET",
        query: [String: String] = [:],
        overrideToken: String? = nil
    ) async throws -> T {
        let data = try await performRequest(path: path, method: method, query: query, bodyData: nil, overrideToken: overrideToken)
        return try decodeEnvelope(data)
    }

    func request<T: Decodable, B: Encodable>(
        _ path: String,
        method: String = "POST",
        body: B,
        query: [String: String] = [:],
        overrideToken: String? = nil
    ) async throws -> T {
        let bodyData = try encoder.encode(body)
        let data = try await performRequest(path: path, method: method, query: query, bodyData: bodyData, overrideToken: overrideToken)
        return try decodeEnvelope(data)
    }

    func requestVoid(
        _ path: String,
        method: String = "POST",
        query: [String: String] = [:],
        overrideToken: String? = nil
    ) async throws {
        _ = try await performRequest(path: path, method: method, query: query, bodyData: nil, overrideToken: overrideToken)
    }

    func requestVoid<B: Encodable>(
        _ path: String,
        method: String = "POST",
        body: B,
        query: [String: String] = [:],
        overrideToken: String? = nil
    ) async throws {
        let bodyData = try encoder.encode(body)
        _ = try await performRequest(path: path, method: method, query: query, bodyData: bodyData, overrideToken: overrideToken)
    }

    // MARK: - Multipart upload

    func upload<T: Decodable>(
        _ path: String,
        fields: [String: String],
        fileFieldName: String,
        fileName: String,
        fileData: Data,
        mimeType: String
    ) async throws -> T {
        let data = try await sendMultipart(
            path: path, fields: fields, fileFieldName: fileFieldName,
            fileName: fileName, fileData: fileData, mimeType: mimeType
        )
        return try decodeEnvelope(data)
    }

    /// For upload endpoints whose success response has no meaningful `data`
    /// payload (e.g. `data: null`) - avoids treating that as a decode failure.
    func uploadVoid(
        _ path: String,
        fields: [String: String],
        fileFieldName: String,
        fileName: String,
        fileData: Data,
        mimeType: String
    ) async throws {
        _ = try await sendMultipart(
            path: path, fields: fields, fileFieldName: fileFieldName,
            fileName: fileName, fileData: fileData, mimeType: mimeType
        )
    }

    private func sendMultipart(
        path: String,
        fields: [String: String],
        fileFieldName: String,
        fileName: String,
        fileData: Data,
        mimeType: String
    ) async throws -> Data {
        let boundary = "Boundary-\(UUID().uuidString)"
        var body = Data()

        for (key, value) in fields {
            body.append("--\(boundary)\r\n".data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n".data(using: .utf8)!)
            body.append("\(value)\r\n".data(using: .utf8)!)
        }

        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"\(fileFieldName)\"; filename=\"\(fileName)\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: \(mimeType)\r\n\r\n".data(using: .utf8)!)
        body.append(fileData)
        body.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)

        var request = try makeRequest(path: path, method: "POST", query: [:])
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        request.httpBody = body

        return try await send(request)
    }

    // MARK: - Internals

    private func makeRequest(path: String, method: String, query: [String: String], overrideToken: String? = nil) throws -> URLRequest {
        var components = URLComponents(
            url: APIConfig.baseURL.appendingPathComponent(path),
            resolvingAgainstBaseURL: false
        )
        if !query.isEmpty {
            components?.queryItems = query.map { URLQueryItem(name: $0.key, value: $0.value) }
        }
        guard let url = components?.url else { throw APIError.invalidResponse }

        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        // The backend reads the raw token from this header with no "Bearer " prefix.
        // overrideToken lets callers (e.g. the forgot-password reset step) authenticate
        // with a short-lived token instead of the stored session token.
        if let token = overrideToken ?? KeychainHelper.shared.token {
            request.setValue(token, forHTTPHeaderField: "Authorization")
        }
        return request
    }

    private func performRequest(
        path: String,
        method: String,
        query: [String: String],
        bodyData: Data?,
        overrideToken: String? = nil
    ) async throws -> Data {
        var request = try makeRequest(path: path, method: method, query: query, overrideToken: overrideToken)
        request.httpBody = bodyData
        return try await send(request)
    }

    private func send(_ request: URLRequest) async throws -> Data {
        let (data, response): (Data, URLResponse)
        do {
            (data, response) = try await URLSession.shared.data(for: request)
        } catch {
            throw APIError.unknown(error)
        }

        guard let http = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }

        if http.statusCode == 401 {
            throw APIError.unauthorized
        }

        guard (200...299).contains(http.statusCode) else {
            if let errorEnvelope = try? decoder.decode(APIErrorEnvelope.self, from: data) {
                throw APIError.server(message: errorEnvelope.message, statusCode: http.statusCode)
            }
            throw APIError.server(message: "Something went wrong (\(http.statusCode))", statusCode: http.statusCode)
        }

        return data
    }

    private func decodeEnvelope<T: Decodable>(_ data: Data) throws -> T {
        do {
            let envelope = try decoder.decode(APIEnvelope<T>.self, from: data)
            guard let value = envelope.data else { throw APIError.invalidResponse }
            return value
        } catch let error as APIError {
            throw error
        } catch {
            throw APIError.decoding(error)
        }
    }
}

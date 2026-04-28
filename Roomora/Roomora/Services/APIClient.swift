import Foundation
import ClerkKit

class APIClient {
    static let shared = APIClient()
    private let baseURL = "https://roomora-api.onrender.com/api/v1"

    func get(path: String, clerk: Clerk) async throws -> Data {
        try await request(method: "GET", path: path, clerk: clerk)
    }

    func post(path: String, body: [String: Any], clerk: Clerk) async throws -> Data {
        try await request(method: "POST", path: path, body: body, clerk: clerk)
    }

    func put(path: String, body: [String: Any], clerk: Clerk) async throws -> Data {
        try await request(method: "PUT", path: path, body: body, clerk: clerk)
    }

    func patch(path: String, body: [String: Any], clerk: Clerk) async throws -> Data {
        try await request(method: "PATCH", path: path, body: body, clerk: clerk)
    }

    func delete(path: String, clerk: Clerk) async throws -> Data {
        try await request(method: "DELETE", path: path, clerk: clerk)
    }

    func decodeData<T: Decodable>(_ type: T.Type, from data: Data) throws -> T {
        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
        guard let inner = json?["data"] else {
            throw APIError.invalidResponse
        }
        let innerData = try JSONSerialization.data(withJSONObject: inner)
        return try JSONDecoder.api.decode(T.self, from: innerData)
    }

    private func request(
        method: String,
        path: String,
        body: [String: Any]? = nil,
        clerk: Clerk
    ) async throws -> Data {
        guard let url = URL(string: baseURL + path) else {
            throw APIError.invalidURL
        }

        var req = URLRequest(url: url)
        req.httpMethod = method
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")

        if let token = try? await clerk.session?.getToken() {
            req.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        if let body {
            req.httpBody = try JSONSerialization.data(withJSONObject: body)
        }

        let (data, response) = try await URLSession.shared.data(for: req)

        guard let http = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }

        guard (200...299).contains(http.statusCode) else {
            let errorBody = try? JSONDecoder().decode(ErrorResponse.self, from: data)
            let message = errorBody?.error ?? "Server error (\(http.statusCode))"
            print("❌ API \(http.statusCode) — \(method) \(path): \(message)")
            if let raw = String(data: data, encoding: .utf8) { print("   Raw: \(raw.prefix(300))") }
            throw APIError.server(status: http.statusCode, message: message)
        }

        return data
    }
}

// Encodable & Decodable
struct ErrorResponse: Codable {
    let error: String
}

enum APIError: LocalizedError {
    case invalidURL
    case invalidResponse
    case server(status: Int, message: String)

    var errorDescription: String? {
        switch self {
        case .invalidURL: return "Invalid URL"
        case .invalidResponse: return "Invalid response"
        case .server(_, let message): return message
        }
    }
}

extension JSONDecoder {
    static let api: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder
    }()
}


extension ISO8601DateFormatter {
    static let withFractional: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter
    }()
}

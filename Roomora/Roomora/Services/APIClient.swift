import Foundation
import ClerkKit

actor APIClient {
    static let shared = APIClient()
    private let baseURL = "https://roomora-api.onrender.com/api/v1"

    /// Syncs  Clerk user to the rails backend, stores role and profile info.
    func syncUser(
        clerk: Clerk,
        role: String,
        firstName: String,
        lastName: String,
        email: String,
        phone: String?
    ) async throws -> SyncResponse {
        var body: [String: Any] = [
            "role": role,
            "first_name": firstName,
            "last_name": lastName,
            "email": email
        ]
        if let phone, !phone.isEmpty {
            body["phone"] = phone
        }

        let data = try await request(
            method: "POST",
            path: "/auth/sync",
            body: ["user": body],
            clerk: clerk
        )
        let decoded = try JSONDecoder.api.decode(DataWrapper<SyncResponse>.self, from: data)
        return decoded.data
    }

    /// Grabs current user's profile data from  backend.
    func fetchProfile(clerk: Clerk) async throws -> SyncResponse {
        let data = try await request(method: "GET", path: "/profile", clerk: clerk)
        let decoded = try JSONDecoder.api.decode(DataWrapper<SyncResponse>.self, from: data)
        return decoded.data
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

        // Attach Clerk session token
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
            throw APIError.server(status: http.statusCode, message: errorBody?.error ?? "Unknown error")
        }

        return data
    }
}

struct SyncResponse: Codable {
    let id: String
    let clerkId: String
    let role: String
    let firstName: String
    let lastName: String
    let email: String
    let phone: String?
    let avatarUrl: String?
    let bio: String?
    let university: String?
    let verified: Bool
    let createdAt: String
    let updatedAt: String
}

struct DataWrapper<T: Codable>: Codable {
    let data: T
}

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

// rails api works in snake_case
extension JSONDecoder {
    static let api: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder
    }()
}

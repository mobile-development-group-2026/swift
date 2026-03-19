import Foundation
import ClerkKit

extension APIClient {

    func syncUser(
        clerk: Clerk,
        role: String,
        firstName: String,
        lastName: String,
        email: String,
        phone: String?
    ) async throws -> SyncResponse {
        var userBody: [String: Any] = [
            "role": role,
            "first_name": firstName,
            "last_name": lastName,
            "email": email
        ]
        if let phone, !phone.isEmpty {
            userBody["phone"] = phone
        }

        let data = try await post(
            path: "/auth/sync",
            body: ["user": userBody],
            clerk: clerk
        )
        return try decodeData(SyncResponse.self, from: data)
    }

    func fetchProfile(clerk: Clerk) async throws -> SyncResponse {
        let data = try await get(path: "/profile", clerk: clerk)
        return try decodeData(SyncResponse.self, from: data)
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
    let onboarded: Bool?
    let createdAt: String
    let updatedAt: String
}

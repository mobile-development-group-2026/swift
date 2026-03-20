import Foundation
import ClerkKit

extension APIClient {

    // MARK: - Users

    /// Get a public user profile by ID
    func getUser(clerk: Clerk, userId: String) async throws -> UserProfileResponse {
        let data = try await get(path: "/users/\(userId)", clerk: clerk)
        return try decodeData(UserProfileResponse.self, from: data)
    }
}

// MARK: - Response Models

struct UserProfileResponse: Codable {
    let id: String
    let clerkId: String
    let role: String
    let firstName: String
    let lastName: String
    let email: String
    let phone: String?
    let avatarUrl: String?
    let verified: Bool
    let onboarded: Bool?
    let createdAt: String
    let updatedAt: String
    let studentProfile: StudentProfileResponse?
    let lifestyleProfile: LifestyleProfileResponse?

    enum CodingKeys: String, CodingKey {
        case id
        case clerkId
        case role
        case firstName
        case lastName
        case email
        case phone
        case avatarUrl
        case verified
        case onboarded
        case createdAt
        case updatedAt
        case studentProfile
        case lifestyleProfile
    }
}

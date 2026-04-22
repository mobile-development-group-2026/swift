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

struct StudentProfileResponse: Codable {
    let id: String
    let university: String?
    let major: String?
    let birthYear: Int?
    let graduationYear: Int?
    let bio: String?
    let hobbies: [String]?
}

struct LifestyleProfileResponse: Codable {
    let id: String
    let spotsAvailable: Int?
    let moveInMonth: String?
    let genderPreference: Int?
    let sleepSchedule: Int?
    let cleanlinessLevel: Int?
    let lifestyle: [String]?
    let requirements: [String]?
}

struct LandlordProfileResponse: Codable {
    let id: String
    let birthYear: Int?
    let bio: String?
    let hobbies: [String]?
}

struct ListingResponse: Codable, Identifiable, Hashable {
    let id: String
    let userId: String?
    let listingType: String?
    let title: String
    let description: String?
    let propertyType: String?
    let address: String?
    let city: String?
    let state: String?
    let zipCode: String?
    let rent: String
    let securityDeposit: String?
    let availableDate: String?
    let leaseTermMonths: Int?
    let bedrooms: Int?
    let bathrooms: Int?
    let latitude: Double?
    let longitude: Double?
    let amenities: [String]?
    let rules: [String]?
    let status: String
    let favoritesCount: Int?
    let viewsCount: Int?
    let createdAt: String?
    let updatedAt: String?
}

struct ApplicationStudentInfo: Codable {
    let id: String
    let firstName: String
    let lastName: String
    let email: String
    let verified: Bool

    var fullName: String { "\(firstName) \(lastName)" }
}

struct ApplicationListingInfo: Codable {
    let id: String
    let title: String
}

struct ApplicationResponse: Codable, Identifiable {
    let id: String
    let listingId: String
    let studentId: String
    let status: String
    let preferredVisitAt: String?
    let studentNotes: String?
    let landlordNotes: String?
    let reviewedAt: String?
    let createdAt: String
    let updatedAt: String
    let listing: ApplicationListingInfo?
    let student: ApplicationStudentInfo?
}

struct ListingProfileResponse: Codable {
    let id: String
    let maxBudget: Int?
    let propertyType: String?
    let moveInDate: String?
    let leaseLengthMonths: Int?
    let maxDistance: Int?
    let amenities: [String]?
    let preferences: [String]?
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
    let verified: Bool
    let onboarded: Bool?
    let createdAt: String
    let updatedAt: String
    let studentProfile: StudentProfileResponse?
    let lifestyleProfile: LifestyleProfileResponse?
    let listingProfile: ListingProfileResponse?
    let landlordProfile: LandlordProfileResponse?
}

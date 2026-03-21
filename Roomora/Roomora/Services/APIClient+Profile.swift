import Foundation
import ClerkKit

extension APIClient {

    func updateProfile(clerk: Clerk, fields: [String: Any]) async throws -> SyncResponse {
        let data = try await patch(path: "/profile", body: ["user": fields], clerk: clerk)
        return try decodeData(SyncResponse.self, from: data)
    }

    func updateStudentProfile(clerk: Clerk, fields: [String: Any]) async throws -> StudentProfileResponse {
        let data = try await patch(path: "/profile/student", body: ["student_profile": fields], clerk: clerk)
        return try decodeData(StudentProfileResponse.self, from: data)
    }

    func updateLifestyleProfile(clerk: Clerk, fields: [String: Any]) async throws -> LifestyleProfileResponse {
        let data = try await patch(path: "/profile/lifestyle", body: ["lifestyle_profile": fields], clerk: clerk)
        return try decodeData(LifestyleProfileResponse.self, from: data)
    }

    func updateListingProfile(clerk: Clerk, fields: [String: Any]) async throws -> ListingProfileResponse {
        let data = try await patch(path: "/profile/listing_preferences", body: ["listing_profile": fields], clerk: clerk)
        return try decodeData(ListingProfileResponse.self, from: data)
    }

    func createListing(clerk: Clerk, fields: [String: Any]) async throws -> ListingResponse {
        let data = try await post(path: "/listings", body: ["listing": fields], clerk: clerk)
        return try decodeData(ListingResponse.self, from: data)
    }

    func fetchMyListings(clerk: Clerk) async throws -> [ListingResponse] {
        let data = try await get(path: "/listings/mine", clerk: clerk)
        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
        guard let inner = json?["data"] else {
            throw APIError.invalidResponse
        }
        let innerData = try JSONSerialization.data(withJSONObject: inner)
        return try JSONDecoder.api.decode([ListingResponse].self, from: innerData)
    }

    func updateLandlordProfile(clerk: Clerk, fields: [String: Any]) async throws -> LandlordProfileResponse {
        let data = try await patch(path: "/profile/landlord", body: ["landlord_profile": fields], clerk: clerk)
        return try decodeData(LandlordProfileResponse.self, from: data)
    }
}

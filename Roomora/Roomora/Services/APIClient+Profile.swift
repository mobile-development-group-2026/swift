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

    func fetchListing(id: String, clerk: Clerk) async throws -> ListingResponse {
        let data = try await get(path: "/listings/\(id)", clerk: clerk)
        return try decodeData(ListingResponse.self, from: data)
    }

    func postListingPhoto(clerk: Clerk, listingId: String, photoUrl: String) async throws -> ListingPhotoResponse {
        let data = try await post(
            path: "/listings/\(listingId)/photos",
            body: ["photo": ["photo_url": photoUrl]],
            clerk: clerk
        )
        return try decodeData(ListingPhotoResponse.self, from: data)
    }

    func deleteListingPhoto(clerk: Clerk, listingId: String, photoId: String) async throws {
        _ = try await delete(path: "/listings/\(listingId)/photos/\(photoId)", clerk: clerk)
    }
}

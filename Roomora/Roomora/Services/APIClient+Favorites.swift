import Foundation
import ClerkKit

struct FavoriteToggleResponse: Codable {
    let favorited: Bool
    let favoritesCount: Int
}

extension APIClient {

    // GET /api/v1/favorites — current user's favorited listings
    func fetchFavorites(clerk: Clerk) async throws -> [ListingResponse] {
        let data = try await get(path: "/favorites", clerk: clerk)
        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
        guard let inner = json?["data"] else { throw APIError.invalidResponse }
        let innerData = try JSONSerialization.data(withJSONObject: inner)
        return try JSONDecoder.api.decode([ListingResponse].self, from: innerData)
    }

    // POST /api/v1/listings/:id/favorite
    @discardableResult
    func addFavorite(clerk: Clerk, listingId: String) async throws -> FavoriteToggleResponse {
        let data = try await post(path: "/listings/\(listingId)/favorite", body: [:], clerk: clerk)
        return try decodeData(FavoriteToggleResponse.self, from: data)
    }

    // DELETE /api/v1/listings/:id/favorite
    @discardableResult
    func removeFavorite(clerk: Clerk, listingId: String) async throws -> FavoriteToggleResponse {
        let data = try await delete(path: "/listings/\(listingId)/favorite", clerk: clerk)
        return try decodeData(FavoriteToggleResponse.self, from: data)
    }
}

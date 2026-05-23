import Foundation
import ClerkKit

extension APIClient {

    // GET /api/v1/roommates
    func fetchRoommates(clerk: Clerk) async throws -> [RoommateStudent] {
        let data = try await get(path: "/roommates", clerk: clerk)
        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
        guard let inner = json?["data"] else { throw APIError.invalidResponse }
        let innerData = try JSONSerialization.data(withJSONObject: inner)
        return try JSONDecoder.api.decode([RoommateStudent].self, from: innerData)
    }
}

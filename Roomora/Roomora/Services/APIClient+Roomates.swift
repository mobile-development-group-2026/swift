import Foundation
import ClerkKit

extension APIClient {

    func fetchRoommateProfile(id: String, clerk: Clerk) async throws -> RoommateProfileResponse {
        let cacheKey = "roommate_\(id)"

        let data = try await get(path: "/users/\(id)", clerk: clerk)
        let fresh = try decodeData(RoommateProfileResponse.self, from: data)
        CacheService.save(fresh, key: cacheKey)
        return fresh
    }

    func cachedRoommateProfile(id: String) -> RoommateProfileResponse? {
        CacheService.load(RoommateProfileResponse.self, key: "roommate_\(id)")
    }

    
    func prefetchRoommateProfiles(ids: [String], clerk: Clerk) {
        Task.detached(priority: .background) {
            for id in ids {
                guard await self.cachedRoommateProfile(id: id) == nil else { continue }
                _ = try? await self.fetchRoommateProfile(id: id, clerk: clerk)
            }
        }
    }
}

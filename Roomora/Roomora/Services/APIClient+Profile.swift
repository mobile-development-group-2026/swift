import Foundation
import ClerkKit

extension APIClient {

    func updateProfile(clerk: Clerk, fields: [String: Any]) async throws -> SyncResponse {
        let data = try await patch(path: "/profile", body: ["user": fields], clerk: clerk)
        return try decodeData(SyncResponse.self, from: data)
    }
}

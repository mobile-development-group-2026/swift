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
}

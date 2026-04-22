import Foundation
import ClerkKit

extension APIClient {

    // Public listing index — no auth required, but Clerk token is attached if available
    func fetchListings(clerk: Clerk, city: String? = nil) async throws -> [ListingResponse] {
        var path = "/listings?status=active&per_page=50"
        if let city, !city.isEmpty {
            path += "&city=\(city.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? city)"
        }
        let data = try await get(path: path, clerk: clerk)
        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
        guard let inner = json?["data"] else { throw APIError.invalidResponse }
        let innerData = try JSONSerialization.data(withJSONObject: inner)
        return try JSONDecoder.api.decode([ListingResponse].self, from: innerData)
    }

    // GET /api/v1/applications/mine
    // Student: their own applications. Landlord: all received applications.
    func fetchMyApplications(clerk: Clerk) async throws -> [ApplicationResponse] {
        let data = try await get(path: "/applications/mine", clerk: clerk)
        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
        guard let inner = json?["data"] else { throw APIError.invalidResponse }
        let innerData = try JSONSerialization.data(withJSONObject: inner)
        return try JSONDecoder.api.decode([ApplicationResponse].self, from: innerData)
    }

    // POST /api/v1/listings/:id/applications
    @discardableResult
    func createApplication(clerk: Clerk, listingId: String, fields: [String: Any]) async throws -> ApplicationResponse {
        let data = try await post(path: "/listings/\(listingId)/applications", body: ["application": fields], clerk: clerk)
        return try decodeData(ApplicationResponse.self, from: data)
    }

    // PATCH /api/v1/applications/:id
    @discardableResult
    func updateApplication(clerk: Clerk, applicationId: String, fields: [String: Any]) async throws -> ApplicationResponse {
        let data = try await patch(path: "/applications/\(applicationId)", body: ["application": fields], clerk: clerk)
        return try decodeData(ApplicationResponse.self, from: data)
    }
}

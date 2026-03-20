//
//  ListingService.swift
//  Roomora
//
//  Created by Jeronimo Cifci on 20/03/26.
//

import Foundation

class ListingService {
    static let shared = ListingService()
    private let baseURL = "https://roomora-api.onrender.com/api/v1"

    func syncUser(token: String) async throws {
        guard let url = URL(string: "\(baseURL)/auth/sync") else {
            throw URLError(.badURL)
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        let (_, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 || httpResponse.statusCode == 201 else {
            throw URLError(.badServerResponse)
        }
    }

    func searchListings(filters: SearchFilters) async throws -> [Listing] {
        var components = URLComponents(string: "\(baseURL)/listings")!
        components.queryItems = filters.toQueryParams().map {
            URLQueryItem(name: $0.key, value: $0.value)
        }
        guard let url = components.url else { throw URLError(.badURL) }
        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let (data, _) = try await URLSession.shared.data(for: request)
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let decoded = try decoder.decode(ListingsResponse.self, from: data)
        return decoded.data
    }
}

struct ListingResponse: Codable {
    let data: Listing
}

struct ListingsResponse: Codable {
    let data: [Listing]
}

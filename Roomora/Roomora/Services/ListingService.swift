//
//  ListingService.swift
//  
//
//  Created by Jeronimo Cifci on 19/03/26.
//

import Foundation

class ListingService {
    static let shared = ListingService()
    private let baseURL = "https://roomora-api.onrender.com/api/v1"

    func createListing(_ listing: Listing, token: String) async throws -> Listing {
        guard let url = URL(string: "\(baseURL)/listings") else {
            throw URLError(.badURL)
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        let body: [String: Any] = [
            "listing": [
                "listing_type": "property",
                "title": listing.title,
                "description": listing.description,
                "property_type": listing.propertyType,
                "address": listing.address,
                "city": listing.city,
                "state": listing.state,
                "zip_code": listing.zipCode,
                "rent": listing.rent,
                "security_deposit": listing.securityDeposit,
                "utilities_included": listing.utilitiesIncluded,
                "utilities_cost": listing.utilitiesCost,
                "available_date": ISO8601DateFormatter().string(from: listing.availableDate),
                "lease_term_months": listing.leaseTermMonths,
                "bedrooms": listing.bedrooms,
                "bathrooms": listing.bathrooms,
                "pets_allowed": listing.petsAllowed,
                "parties_allowed": listing.partiesAllowed,
                "smoking_allowed": listing.smokingAllowed
            ]
        ]

        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 201 else {
            throw URLError(.badServerResponse)
        }

        let decoded = try JSONDecoder().decode(ListingResponse.self, from: data)
        return decoded.data
    }
}

// MARK: - Response Models
struct ListingResponse: Codable {
    let data: Listing
}

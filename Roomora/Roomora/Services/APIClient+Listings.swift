import Foundation
import ClerkKit

extension APIClient {

    // MARK: - Listings

    /// Get all listings with optional filters
    func getListings(
        clerk: Clerk,
        type: String? = nil,
        city: String? = nil,
        status: String? = nil,
        bedrooms: Int? = nil,
        minPrice: Double? = nil,
        maxPrice: Double? = nil,
        page: Int = 1,
        perPage: Int = 20
    ) async throws -> ListingsResponse {
        var path = "/listings?page=\(page)&per_page=\(perPage)"

        if let type { path += "&type=\(type)" }
        if let city { path += "&city=\(city)" }
        if let status { path += "&status=\(status)" }
        if let bedrooms { path += "&bedrooms=\(bedrooms)" }
        if let minPrice { path += "&min_price=\(minPrice)" }
        if let maxPrice { path += "&max_price=\(maxPrice)" }

        let data = try await get(path: path, clerk: clerk)
        return try JSONDecoder.api.decode(ListingsResponse.self, from: data)
    }

    /// Get a specific listing by ID
    func getListingDetail(clerk: Clerk, listingId: String) async throws -> Listing {
        let data = try await get(path: "/listings/\(listingId)", clerk: clerk)
        return try decodeData(Listing.self, from: data)
    }

    /// Create a new listing
    func createListing(
        clerk: Clerk,
        listing: Listing
    ) async throws -> Listing {
        var listingBody: [String: Any] = [
            "listing_type": listing.listingType,
            "title": listing.title,
            "description": listing.description,
            "address": listing.address,
            "city": listing.city,
            "state": listing.state,
            "zip_code": listing.zipCode,
            "rent": listing.rent,
            "bedrooms": listing.bedrooms,
            "bathrooms": listing.bathrooms,
            "pets_allowed": listing.petsAllowed,
            "parties_allowed": listing.partiesAllowed,
            "smoking_allowed": listing.smokingAllowed,
            "amenities": listing.amenities ?? [],
            "rules": listing.rules ?? []
        ]
        
        // Add optional fields if present
        if let securityDeposit = listing.securityDeposit as Double?, securityDeposit > 0 {
            listingBody["security_deposit"] = securityDeposit
        }
        if listing.utilitiesIncluded {
            listingBody["utilities_included"] = listing.utilitiesIncluded
            listingBody["utilities_cost"] = listing.utilitiesCost
        }
        if let availableDate = listing.availableDate {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            formatter.locale = Locale(identifier: "en_US_POSIX")
            formatter.timeZone = TimeZone(secondsFromGMT: 0)
            listingBody["available_date"] = formatter.string(from: availableDate)
        }
        if let leaseTermMonths = listing.leaseTermMonths {
            listingBody["lease_term_months"] = leaseTermMonths
        }
        if let propertyType = listing.propertyType as String?, !propertyType.isEmpty {
            listingBody["property_type"] = propertyType
        }
        if let latitude = listing.latitude {
            listingBody["latitude"] = latitude
        }
        if let longitude = listing.longitude {
            listingBody["longitude"] = longitude
        }

        // Wrap in root "listing" key as required by Rails
        let body: [String: Any] = ["listing": listingBody]

        let data = try await post(path: "/listings", body: body, clerk: clerk)
        return try decodeData(Listing.self, from: data)
    }

    /// Delete a listing
    func deleteListing(clerk: Clerk, listingId: String) async throws {
        _ = try await delete(path: "/listings/\(listingId)", clerk: clerk)
    }
}

// MARK: - Response Models

struct ListingsResponse: Codable {
    let data: [Listing]
    let meta: PaginationMeta
}

struct PaginationMeta: Codable {
    let total: Int
    let page: Int
    let perPage: Int
    let totalPages: Int

    enum CodingKeys: String, CodingKey {
        case total
        case page
        case perPage
        case totalPages
    }
}

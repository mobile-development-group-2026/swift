import Foundation

struct Listing: Identifiable, Codable, Hashable {
    var id: Int?
    var listingType: String = "property"
    var title: String = ""
    var description: String = ""
    var propertyType: String = ""
    var address: String = ""
    var city: String = ""
    var state: String = ""
    var zipCode: String = ""
    var rent: Double = 0
    var securityDeposit: Double = 0
    var utilitiesIncluded: Bool = false
    var utilitiesCost: Double = 0
    var availableDate: Date = Date()
    var leaseTermMonths: Int = 12
    var bedrooms: Int = 1
    var bathrooms: Int = 1
    var petsAllowed: Bool = false
    var partiesAllowed: Bool = false
    var smokingAllowed: Bool = false
    var status: String = "active"

    enum CodingKeys: String, CodingKey {
        case id
        case listingType = "listing_type"
        case title
        case description
        case propertyType = "property_type"
        case address
        case city
        case state
        case zipCode = "zip_code"
        case rent
        case securityDeposit = "security_deposit"
        case utilitiesIncluded = "utilities_included"
        case utilitiesCost = "utilities_cost"
        case availableDate = "available_date"
        case leaseTermMonths = "lease_term_months"
        case bedrooms
        case bathrooms
        case petsAllowed = "pets_allowed"
        case partiesAllowed = "parties_allowed"
        case smokingAllowed = "smoking_allowed"
        case status
    }
}

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
}

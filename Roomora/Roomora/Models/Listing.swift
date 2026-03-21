import Foundation

struct Listing: Identifiable, Hashable {
    let id: String
    let listingType: String
    let title: String
    let description: String?
    let propertyType: String?
    let address: String
    let city: String
    let state: String?
    let zipCode: String?
    let latitude: Double?
    let longitude: Double?
    let rent: Double
    let securityDeposit: Double?
    let utilitiesIncluded: Bool
    let utilitiesCost: Double?
    let availableDate: Date?
    let leaseTermMonths: Int?
    let bedrooms: Int?
    let bathrooms: Int?
    let petsAllowed: Bool
    let partiesAllowed: Bool
    let smokingAllowed: Bool
    let status: String
}

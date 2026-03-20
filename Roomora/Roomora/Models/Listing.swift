import Foundation

struct Listing: Identifiable, Codable, Hashable {
    var id: String? = nil
    var userId: String? = nil
    var listingType: String = "property"
    var title: String = ""
    var description: String = ""
    var propertyType: String = ""
    var address: String = ""
    var city: String = ""
    var state: String = ""
    var zipCode: String = ""
    var latitude: Double? = nil
    var longitude: Double? = nil
    var rent: Double = 0
    var securityDeposit: Double = 0
    var utilitiesIncluded: Bool = false
    var utilitiesCost: Double = 0
    var availableDate: Date? = nil
    var leaseTermMonths: Int? = nil
    var bedrooms: Int = 1
    var bathrooms: Int = 1
    var petsAllowed: Bool = false
    var partiesAllowed: Bool = false
    var smokingAllowed: Bool = false
    var status: String = "active"
    var photos: [ListingPhoto]? = nil
    var createdAt: String? = nil
    var updatedAt: String? = nil

    enum CodingKeys: String, CodingKey {
        case id
        case userId
        case listingType
        case title
        case description
        case propertyType
        case address
        case city
        case state
        case zipCode
        case latitude
        case longitude
        case rent
        case securityDeposit
        case utilitiesIncluded
        case utilitiesCost
        case availableDate
        case leaseTermMonths
        case bedrooms
        case bathrooms
        case petsAllowed
        case partiesAllowed
        case smokingAllowed
        case status
        case photos
        case createdAt
        case updatedAt
    }

    init(
        id: String? = nil,
        userId: String? = nil,
        listingType: String = "property",
        title: String = "",
        description: String = "",
        propertyType: String = "",
        address: String = "",
        city: String = "",
        state: String = "",
        zipCode: String = "",
        latitude: Double? = nil,
        longitude: Double? = nil,
        rent: Double = 0,
        securityDeposit: Double = 0,
        utilitiesIncluded: Bool = false,
        utilitiesCost: Double = 0,
        availableDate: Date? = nil,
        leaseTermMonths: Int? = nil,
        bedrooms: Int = 1,
        bathrooms: Int = 1,
        petsAllowed: Bool = false,
        partiesAllowed: Bool = false,
        smokingAllowed: Bool = false,
        status: String = "active",
        photos: [ListingPhoto]? = nil,
        createdAt: String? = nil,
        updatedAt: String? = nil
    ) {
        self.id = id
        self.userId = userId
        self.listingType = listingType
        self.title = title
        self.description = description
        self.propertyType = propertyType
        self.address = address
        self.city = city
        self.state = state
        self.zipCode = zipCode
        self.latitude = latitude
        self.longitude = longitude
        self.rent = rent
        self.securityDeposit = securityDeposit
        self.utilitiesIncluded = utilitiesIncluded
        self.utilitiesCost = utilitiesCost
        self.availableDate = availableDate
        self.leaseTermMonths = leaseTermMonths
        self.bedrooms = bedrooms
        self.bathrooms = bathrooms
        self.petsAllowed = petsAllowed
        self.partiesAllowed = partiesAllowed
        self.smokingAllowed = smokingAllowed
        self.status = status
        self.photos = photos
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decodeIfPresent(String.self, forKey: .id)
        userId = try container.decodeIfPresent(String.self, forKey: .userId)
        listingType = try container.decodeIfPresent(String.self, forKey: .listingType) ?? "property"
        title = try container.decodeIfPresent(String.self, forKey: .title) ?? ""
        description = try container.decodeIfPresent(String.self, forKey: .description) ?? ""
        propertyType = try container.decodeIfPresent(String.self, forKey: .propertyType) ?? ""
        address = try container.decodeIfPresent(String.self, forKey: .address) ?? ""
        city = try container.decodeIfPresent(String.self, forKey: .city) ?? ""
        state = try container.decodeIfPresent(String.self, forKey: .state) ?? ""
        // Helper to decode Double from either Double or String
        func decodeDouble(forKey key: CodingKeys) throws -> Double {
            if let doubleValue = try? container.decodeIfPresent(Double.self, forKey: key) {
                return doubleValue
            } else if let stringValue = try? container.decodeIfPresent(String.self, forKey: key) {
                return Double(stringValue) ?? 0
            }
            return 0
        }

        zipCode = try container.decodeIfPresent(String.self, forKey: .zipCode) ?? ""
        latitude = try container.decodeIfPresent(Double.self, forKey: .latitude)
        longitude = try container.decodeIfPresent(Double.self, forKey: .longitude)
        
        rent = try decodeDouble(forKey: .rent)
        securityDeposit = try decodeDouble(forKey: .securityDeposit)
        utilitiesIncluded = try container.decodeIfPresent(Bool.self, forKey: .utilitiesIncluded) ?? false
        utilitiesCost = try decodeDouble(forKey: .utilitiesCost)
        
        // Handle Date decoding flexibly (date string or full iso8601)
        if let directDate = try? container.decodeIfPresent(Date.self, forKey: .availableDate) {
            availableDate = directDate
        } else if let dateString = try? container.decodeIfPresent(String.self, forKey: .availableDate) {
             let formatter = DateFormatter()
             formatter.dateFormat = "yyyy-MM-dd"
             if let date = formatter.date(from: dateString) {
                 availableDate = date
             } else {
                 let isoFormatter = ISO8601DateFormatter()
                 availableDate = isoFormatter.date(from: dateString)
             }
        } else {
            availableDate = nil
        }
        
        leaseTermMonths = try container.decodeIfPresent(Int.self, forKey: .leaseTermMonths)
        bedrooms = try container.decodeIfPresent(Int.self, forKey: .bedrooms) ?? 1
        bathrooms = try container.decodeIfPresent(Int.self, forKey: .bathrooms) ?? 1
        petsAllowed = try container.decodeIfPresent(Bool.self, forKey: .petsAllowed) ?? false
        partiesAllowed = try container.decodeIfPresent(Bool.self, forKey: .partiesAllowed) ?? false
        smokingAllowed = try container.decodeIfPresent(Bool.self, forKey: .smokingAllowed) ?? false
        status = try container.decodeIfPresent(String.self, forKey: .status) ?? "active"
        photos = try container.decodeIfPresent([ListingPhoto].self, forKey: .photos)
        createdAt = try container.decodeIfPresent(String.self, forKey: .createdAt)
        updatedAt = try container.decodeIfPresent(String.self, forKey: .updatedAt)
    }
}

struct ListingPhoto: Codable, Hashable, Identifiable {
    let id: String
    let photoUrl: String?
    let position: Int?

    enum CodingKeys: String, CodingKey {
        case id
        case photoUrl = "photo_url"
        case position
    }
}

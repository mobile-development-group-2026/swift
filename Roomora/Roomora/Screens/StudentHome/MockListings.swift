import Foundation

struct Listing: Identifiable {
    let id = UUID()
    let title: String
    let location: String
    let price: Int
    let period: String
    let type: String
    let size: String?
    let distance: String
    let moveIn: String
    let leaseTerm: String
    let amenities: [String]
    let tags: [ListingTag]
    let compatibility: Int?
    let isVerifiedLandlord: Bool
    let flashSale: String?
    let imageSystemName: String
}

enum ListingTag {
    case new
    case hot

    var label: String {
        switch self {
        case .new: "New"
        case .hot: "🔥 Hot"
        }
    }
}

enum MockListings {
    static let featured = Listing(
        title: "Bright Studio on University Ave.",
        location: "Gainesville, FL",
        price: 850,
        period: "month",
        type: "Studio",
        size: "38m²",
        distance: "900m to campus",
        moveIn: "Available now",
        leaseTerm: "12 months",
        amenities: ["📶 WiFi", "🧺 Laundry", "❄️ AC", "🛋 Furnished"],
        tags: [],
        compatibility: 87,
        isVerifiedLandlord: true,
        flashSale: "Flash sale — 15% off first month",
        imageSystemName: "building.2.fill"
    )

    static let nearby: [Listing] = [
        Listing(
            title: "Shared room · Tivoli",
            location: "Tivoli Apartments",
            price: 620,
            period: "mo",
            type: "Shared room",
            size: nil,
            distance: "1.2km",
            moveIn: "Move-in Aug 1",
            leaseTerm: "12 months",
            amenities: ["WiFi", "Students only", "No pets"],
            tags: [.new],
            compatibility: nil,
            isVerifiedLandlord: false,
            flashSale: nil,
            imageSystemName: "house.fill"
        ),
        Listing(
            title: "1BR · Frat Row",
            location: "Frat Row",
            price: 1100,
            period: "mo",
            type: "1BR",
            size: nil,
            distance: "600m",
            moveIn: "Move-in Aug 15",
            leaseTerm: "6 months",
            amenities: ["Parking", "Gym", "Balcony"],
            tags: [.hot],
            compatibility: nil,
            isVerifiedLandlord: false,
            flashSale: nil,
            imageSystemName: "building.fill"
        ),
        Listing(
            title: "Studio · Downtown",
            location: "Downtown",
            price: 780,
            period: "mo",
            type: "Studio",
            size: nil,
            distance: "300m",
            moveIn: "Available now",
            leaseTerm: "12 months",
            amenities: ["WiFi", "AC", "Furnished"],
            tags: [.new],
            compatibility: nil,
            isVerifiedLandlord: false,
            flashSale: nil,
            imageSystemName: "house.lodge.fill"
        ),
    ]

    static let availableCount = 24
}

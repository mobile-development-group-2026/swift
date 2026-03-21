import Foundation

struct LandlordListing: Identifiable {
    let id = UUID()
    let title: String
    let address: String
    let price: Int
    let period: String
    let type: String
    let status: ListingStatus
    let views: Int
    let applications: Int
    let imageSystemName: String
}

enum ListingStatus: String {
    case active = "Active"
    case pending = "Pending"
    case draft = "Draft"
}

struct TenantApplication: Identifiable {
    let id = UUID()
    let name: String
    let university: String
    let moveIn: String
    let compatibility: Int
    let verified: Bool
}

enum MockLandlordData {
    static let stats: [(icon: String, label: String, value: String)] = [
        ("eye.fill", "Views", "128"),
        ("doc.text.fill", "Applications", "12"),
        ("house.fill", "Listings", "3"),
        ("star.fill", "Rating", "4.8"),
    ]

    static let listings: [LandlordListing] = [
        LandlordListing(
            title: "Bright Studio on University Ave.",
            address: "123 University Ave, Gainesville, FL",
            price: 850,
            period: "mo",
            type: "Studio · 38m²",
            status: .active,
            views: 84,
            applications: 7,
            imageSystemName: "building.2.fill"
        ),
        LandlordListing(
            title: "2BR near Frat Row",
            address: "456 College St, Gainesville, FL",
            price: 1100,
            period: "mo",
            type: "2BR · 65m²",
            status: .active,
            views: 32,
            applications: 3,
            imageSystemName: "building.fill"
        ),
        LandlordListing(
            title: "Shared Room · Downtown",
            address: "789 Main St, Gainesville, FL",
            price: 620,
            period: "mo",
            type: "Shared · 22m²",
            status: .draft,
            views: 0,
            applications: 0,
            imageSystemName: "house.lodge.fill"
        ),
    ]

    static let recentApplications: [TenantApplication] = [
        TenantApplication(
            name: "Sofia Martinez",
            university: "UF – Computer Science",
            moveIn: "Aug 1",
            compatibility: 92,
            verified: true
        ),
        TenantApplication(
            name: "James Chen",
            university: "UF – Business",
            moveIn: "Aug 15",
            compatibility: 85,
            verified: true
        ),
        TenantApplication(
            name: "Ana López",
            university: "UF – Biology",
            moveIn: "Sep 1",
            compatibility: 78,
            verified: false
        ),
    ]
}

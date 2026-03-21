import SwiftUI

@Observable
class ListingPreferencesViewModel {
    var maxBudget: Int? = 850
    var propertyType: String?
    var moveInDate: Date = Date()
    var leaseLength: Int = 6
    var maxDistance: Int?                    // 0=500m, 1=1km, 2=2km, 3=any
    var selectedAmenities: Set<String> = []
    var selectedPreferences: Set<String> = []

    static let budgetOptions = [300, 600, 900, 1200]

    static let propertyTypes: [(emoji: String, label: String, sub: String)] = [
        ("🛋", "Studio", "Private, compact space"),
        ("🚪", "1 Bedroom", "Separate bedroom & living"),
        ("🏠", "Shared room", "Split cost with roommates"),
        ("🏢", "Any", "Show me everything"),
    ]

    static let leaseOptions = [3, 6, 12]

    static let distanceOptions: [(label: String, value: Int)] = [
        ("≤ 500m", 0), ("≤ 1 km", 1), ("≤ 2 km", 2), ("Any", 3)
    ]

    static let amenities: [(emoji: String, label: String)] = [
        ("📶", "WiFi"), ("🧺", "Laundry"), ("❄️", "AC"),
        ("🛋", "Furnished"), ("🐾", "Pet-friendly"), ("🏋️", "Gym"),
    ]

    static let preferences: [(emoji: String, label: String, sub: String)] = [
        ("🚭", "Smoke-free", "Only non-smoking units"),
        ("🎓", "Students only", "Verified students as tenants"),
        ("📸", "Photos required", "Only listings with photos"),
    ]

    func toggleAmenity(_ item: String) {
        if selectedAmenities.contains(item) {
            selectedAmenities.remove(item)
        } else {
            selectedAmenities.insert(item)
        }
    }

    func togglePreference(_ item: String) {
        if selectedPreferences.contains(item) {
            selectedPreferences.remove(item)
        } else {
            selectedPreferences.insert(item)
        }
    }
}

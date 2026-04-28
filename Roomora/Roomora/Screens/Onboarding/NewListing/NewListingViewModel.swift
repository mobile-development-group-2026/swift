import SwiftUI
import PhotosUI

@Observable
class NewListingViewModel {
    var title = ""
    var monthlyRent = ""
    var securityDeposit = ""
    var propertyType: String?
    var leaseLength = "12 months"
    var availableFrom = Date()
    var selectedAmenities: Set<String> = []
    var selectedRules: Set<String> = []
    var description = ""

    // Photos
    var selectedPhotos: [PhotosPickerItem] = []
    var isUploadingPhotos = false

    // Location
    var city = ""
    var address = ""
    var state = ""
    var zipCode = ""

    // Rooms
    var bedrooms = 1
    var bathrooms = 1

    static let propertyTypes = [
        "Shared room", "Studio", "1 bedroom", "2 bedrooms", "3+ bedrooms"
    ]

    static let leaseOptions = ["3 months", "6 months", "12 months", "24 months"]

    static let amenities = [
        "WiFi", "Laundry", "Parking", "AC", "Gym", "Pool", "Balcony", "Furnished"
    ]

    static let rules = [
        "No smoking", "No parties", "No pets", "No overnight guests",
        "Quiet after 10 pm", "Students only"
    ]

    let descriptionMinChars = 10

    func toggleAmenity(_ item: String) {
        if selectedAmenities.contains(item) {
            selectedAmenities.remove(item)
        } else {
            selectedAmenities.insert(item)
        }
    }

    func toggleRule(_ item: String) {
        if selectedRules.contains(item) {
            selectedRules.remove(item)
        } else {
            selectedRules.insert(item)
        }
    }

    /// Lenient — used by onboarding (just needs title + rent to advance).
    var canContinue: Bool {
        !title.isEmpty && !monthlyRent.isEmpty
    }

    /// Strict — used by the standalone Create Listing form.
    var canSubmit: Bool {
        !title.isEmpty &&
        !monthlyRent.isEmpty &&
        propertyType != nil &&
        !city.isEmpty &&
        !address.isEmpty &&
        description.count >= descriptionMinChars
    }

    // MARK: - Draft persistence

    private struct Draft: Codable {
        var title: String
        var monthlyRent: String
        var securityDeposit: String
        var propertyType: String?
        var leaseLength: String
        var availableFrom: Date
        var selectedAmenities: [String]
        var selectedRules: [String]
        var description: String
        var city: String
        var address: String
        var state: String
        var zipCode: String
        var bedrooms: Int
        var bathrooms: Int
    }

    private static let cacheKey = "onboarding_new_listing"

    func save() {
        let draft = Draft(title: title, monthlyRent: monthlyRent, securityDeposit: securityDeposit,
                          propertyType: propertyType, leaseLength: leaseLength, availableFrom: availableFrom,
                          selectedAmenities: Array(selectedAmenities), selectedRules: Array(selectedRules),
                          description: description, city: city, address: address, state: state,
                          zipCode: zipCode, bedrooms: bedrooms, bathrooms: bathrooms)
        CacheService.save(draft, key: Self.cacheKey)
    }

    func restore() {
        guard let draft = CacheService.load(Draft.self, key: Self.cacheKey) else { return }
        title = draft.title
        monthlyRent = draft.monthlyRent
        securityDeposit = draft.securityDeposit
        propertyType = draft.propertyType
        leaseLength = draft.leaseLength
        availableFrom = draft.availableFrom
        selectedAmenities = Set(draft.selectedAmenities)
        selectedRules = Set(draft.selectedRules)
        description = draft.description
        city = draft.city
        address = draft.address
        state = draft.state
        zipCode = draft.zipCode
        bedrooms = draft.bedrooms
        bathrooms = draft.bathrooms
    }

    static func clearDraft() {
        CacheService.clear(key: cacheKey)
    }
}

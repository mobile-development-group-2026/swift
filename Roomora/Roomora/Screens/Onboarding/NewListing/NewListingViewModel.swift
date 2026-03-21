import SwiftUI

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

    let descriptionMinChars = 80

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

    var canContinue: Bool {
        !title.isEmpty && !monthlyRent.isEmpty
    }
}

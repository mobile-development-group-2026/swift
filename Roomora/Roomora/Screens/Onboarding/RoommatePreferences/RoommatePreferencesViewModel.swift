import SwiftUI

@Observable
class RoommatePreferencesViewModel {
    var spotsAvailable = 1
    var moveInMonth: String?
    var genderPreference: String?
    var sleepSchedule: String?
    var cleanliness: String?
    var selectedLifestyle: Set<String> = []
    var selectedRequirements: Set<String> = []

    func toggleLifestyle(_ item: String) {
        if selectedLifestyle.contains(item) {
            selectedLifestyle.remove(item)
        } else {
            selectedLifestyle.insert(item)
        }
    }

    func toggleRequirement(_ item: String) {
        if selectedRequirements.contains(item) {
            selectedRequirements.remove(item)
        } else {
            selectedRequirements.insert(item)
        }
    }
}

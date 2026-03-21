import SwiftUI

@Observable
class RoommatePreferencesViewModel {
    var spotsAvailable = 1
    var moveInMonth: String?
    var genderPreference: Int?       // 0=no preference, 1=same as me, 2=women only, 3=men only
    var sleepSchedule: Int?          // 0=early_bird, 1=night_owl, 2=no_preference
    var cleanliness: Int?            // 0=very_tidy, 1=moderate, 2=relaxed
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

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

    // MARK: - Draft persistence

    private struct Draft: Codable {
        var spotsAvailable: Int
        var moveInMonth: String?
        var genderPreference: Int?
        var sleepSchedule: Int?
        var cleanliness: Int?
        var selectedLifestyle: [String]
        var selectedRequirements: [String]
    }

    private static let cacheKey = "onboarding_roommate_prefs"

    func save() {
        let draft = Draft(spotsAvailable: spotsAvailable, moveInMonth: moveInMonth,
                          genderPreference: genderPreference, sleepSchedule: sleepSchedule,
                          cleanliness: cleanliness,
                          selectedLifestyle: Array(selectedLifestyle),
                          selectedRequirements: Array(selectedRequirements))
        CacheService.save(draft, key: Self.cacheKey)
    }

    func restore() {
        guard let draft = CacheService.load(Draft.self, key: Self.cacheKey) else { return }
        spotsAvailable = draft.spotsAvailable
        moveInMonth = draft.moveInMonth
        genderPreference = draft.genderPreference
        sleepSchedule = draft.sleepSchedule
        cleanliness = draft.cleanliness
        selectedLifestyle = Set(draft.selectedLifestyle)
        selectedRequirements = Set(draft.selectedRequirements)
    }

    static func clearDraft() {
        CacheService.clear(key: cacheKey)
    }
}

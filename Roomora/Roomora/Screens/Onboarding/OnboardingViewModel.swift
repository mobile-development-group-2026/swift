import SwiftUI
import PhotosUI
import ClerkKit

@Observable
class OnboardingViewModel {
    var step = 0
    let totalSteps = 4
    var isLoading = false
    var errorMessage: String?

    // Step 2 — Situation
    var situation: HousingSituation?

    // Step 3 — Student preferences
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

    // Step 1 — Profile
    var bio = ""
    var university = ""
    var birthYear = ""
    var graduationYear = ""
    var selectedHobbies: Set<String> = []
    let maxHobbies = 5
    var profilePhoto: Image?
    var photoPickerItem: PhotosPickerItem?

    static let hobbies = [
        "📚 Reading", "😴 Sleeping", "🎣 Fishing", "🌙 Star gazing",
        "🧗 Rock climbing", "👾 Netflix", "🏃 Running", "🏕 Camping",
        "🎮 Video games", "🍳 Cooking", "✍️ Journaling", "🥳 Partying"
    ]

    func toggleHobby(_ hobby: String) {
        if selectedHobbies.contains(hobby) {
            selectedHobbies.remove(hobby)
        } else if selectedHobbies.count < maxHobbies {
            selectedHobbies.insert(hobby)
        }
    }

    func nextStep() {
        if step < totalSteps - 1 {
            step += 1
        }
    }

    func previousStep() {
        if step > 0 {
            step -= 1
        }
    }

    var isLastStep: Bool { step == totalSteps - 1 }

    var canContinue: Bool {
        switch step {
        case 0:
            /*
             !bio.trimmingCharacters(in: .whitespaces).isEmpty
                 && !university.trimmingCharacters(in: .whitespaces).isEmpty
                 && selectedHobbies.count > 0
             */
            return selectedHobbies.count > 0
        case 1:
            return situation != nil
        default: return true
        }
    }

    func complete(clerk: Clerk, session: UserSession) async {
        isLoading = true
        errorMessage = nil
        do {
            let profile = try await APIClient.shared.updateProfile(
                clerk: clerk,
                fields: ["onboarded": true]
            )
            session.profile = profile
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
}

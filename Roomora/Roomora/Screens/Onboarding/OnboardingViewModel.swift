import SwiftUI
import ClerkKit

@Observable
class OnboardingViewModel {
    var step = 0
    let totalSteps = 4
    var isLoading = false
    var errorMessage: String?

    // Step 1 — Profile
    var bio = ""
    var selectedHobbies: Set<String> = []
    let maxHobbies = 5

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

import SwiftUI
import PhotosUI
import ClerkKit

@Observable
class OnboardingViewModel {
    var step = 0
    let totalSteps = 4
    var isLoading = false
    var errorMessage: String?

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
            return !bio.trimmingCharacters(in: .whitespaces).isEmpty
                && !university.trimmingCharacters(in: .whitespaces).isEmpty
                && selectedHobbies.count > 0
        default: return true
        }
    }

    func complete(clerk: Clerk, session: UserSession) async {
        isLoading = true
        errorMessage = nil
        do {
            // Save student profile fields
            var studentFields: [String: Any] = [
                "bio": bio,
                "university": university
            ]
            if let year = Int(birthYear) {
                studentFields["birth_year"] = year
            }
            if let year = Int(graduationYear) {
                studentFields["graduation_year"] = year
            }
            _ = try await APIClient.shared.updateStudentProfile(
                clerk: clerk,
                fields: studentFields
            )

            // Mark onboarded
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

import SwiftUI
import ClerkKit

@Observable
class OnboardingViewModel {
    var step = 0
    let totalSteps = 3
    var isLoading = false
    var errorMessage: String?
    var showCelebration = false
    private var completedProfile: SyncResponse?

    // child view models
    var buildProfile = BuildYourProfileViewModel()
    var situation = RoommateSituationViewModel()
    var preferences = RoommatePreferencesViewModel()

    func nextStep(clerk: Clerk) async {
        if step == 0 {
            await saveStudentProfile(clerk: clerk)
        }
        if step < totalSteps - 1 {
            step += 1
        }
    }

    private func saveStudentProfile(clerk: Clerk) async {
        isLoading = true
        errorMessage = nil
        var fields: [String: Any] = [:]

        let bp = buildProfile
        if !bp.university.isEmpty { fields["university"] = bp.university }
        if let major = bp.major { fields["major"] = major }
        if let year = bp.birthYear { fields["birth_year"] = year }
        if let year = bp.graduationYear { fields["graduation_year"] = year }
        if !bp.bio.isEmpty { fields["bio"] = bp.bio }
        if !bp.selectedHobbies.isEmpty {
            // Strip emoji prefixes (e.g. "📚 Reading" → "Reading")
            let cleaned = bp.selectedHobbies.map { hobby in
                hobby.drop(while: { !$0.isASCII || $0.isWhitespace })
                    .trimmingCharacters(in: .whitespaces)
            }.sorted()
            fields["hobbies"] = cleaned
        }

        guard !fields.isEmpty else {
            isLoading = false
            return
        }

        do {
            _ = try await APIClient.shared.updateStudentProfile(clerk: clerk, fields: fields)
        } catch {
            print("saveStudentProfile failed: \(error)")
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    func previousStep() {
        if step > 0 {
            step -= 1
        }
    }

    var isLastStep: Bool { step == totalSteps - 1 }

    var canContinue: Bool {
        switch step {
        case 0: return buildProfile.canContinue
        case 1: return situation.canContinue
        default: return true
        }
    }

    func complete(clerk: Clerk) async {
        isLoading = true
        errorMessage = nil
        do {
            let profile = try await APIClient.shared.updateProfile(
                clerk: clerk,
                fields: ["onboarded": true]
            )
            completedProfile = profile
            showCelebration = true
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    func finishOnboarding(session: UserSession) {
        session.profile = completedProfile
    }
}

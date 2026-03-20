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

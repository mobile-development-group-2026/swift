import SwiftUI
import ClerkKit

@Observable
class OnboardingViewModel {
    var step = 0
    let totalSteps = 4
    var isLoading = false
    var errorMessage: String?

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

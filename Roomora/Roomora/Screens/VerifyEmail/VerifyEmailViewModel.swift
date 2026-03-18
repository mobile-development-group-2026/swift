import SwiftUI
import ClerkKit

@Observable
class VerifyEmailViewModel {
    var code = ""
    var isLoading = false
    var errorMessage: String?

    /// Returns `true` if verification succeeded and the view should dismiss.
    func verify(clerk: Clerk) async -> Bool {
        isLoading = true
        errorMessage = nil
        do {
            guard let signUp = clerk.client?.signUp else {
                isLoading = false
                return false
            }
            try await signUp.verifyEmailCode(code)
            isLoading = false
            return true
        } catch {
            errorMessage = error.localizedDescription
            isLoading = false
            return false
        }
    }
}

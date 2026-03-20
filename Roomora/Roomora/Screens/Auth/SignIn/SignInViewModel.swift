import SwiftUI
import ClerkKit

@Observable
class SignInViewModel {
    var email = ""
    var password = ""
    var isLoading = false
    var errorMessage: String?

    var buttonTitle: String {
        isLoading ? "Signing in..." : "Sign In  →"
    }

    /// Returns `true` if sign-in completed and the view should dismiss.
    func signIn(clerk: Clerk) async -> Bool {
        isLoading = true
        errorMessage = nil
        do {
            let signIn = try await clerk.auth.signInWithPassword(
                identifier: email,
                password: password
            )

            guard signIn.status == .complete else {
                isLoading = false
                return false
            }

            isLoading = false
            return true
        } catch {
            print("signIn failed: \(error)")
            errorMessage = error.localizedDescription
            isLoading = false
            return false
        }
    }
}

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

    /// Attempts sign-in. On success, Clerk sets clerk.user which
    /// triggers ContentView to dismiss the sheet and load the profile.
    /// Returns `true` if sign-in succeeded and the sheet should dismiss.
    func signIn(clerk: Clerk, session: UserSession) async -> Bool {
        isLoading = true
        errorMessage = nil
        do {
            _ = try await clerk.auth.signInWithPassword(
                identifier: email,
                password: password
            )

            // Reset session so ContentView picks up the load
            session.pendingSync = nil
            session.isLoaded = false

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

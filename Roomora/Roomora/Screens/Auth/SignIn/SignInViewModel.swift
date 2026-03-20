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
            let signIn = try await clerk.auth.signInWithPassword(
                identifier: email,
                password: password
            )

            // Wait briefly for Clerk to establish the session
            try? await Task.sleep(for: .seconds(1))

            // Load profile directly — don't rely on clerk.user observation
            session.pendingSync = nil
            await session.load(clerk: clerk)

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

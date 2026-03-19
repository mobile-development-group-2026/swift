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

            // Sync with backend — finds existing user by clerk_id
            if let user = clerk.user {
                _ = try await APIClient.shared.syncUser(
                    clerk: clerk,
                    role: "", // ignored for existing users
                    firstName: user.firstName ?? "",
                    lastName: user.lastName ?? "",
                    email: email,
                    phone: nil
                )
            }

            isLoading = false
            return true
        } catch {
            errorMessage = error.localizedDescription
            isLoading = false
            return false
        }
    }
}

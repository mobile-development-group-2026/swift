import SwiftUI
import ClerkKit

@Observable
class VerifyEmailViewModel {
    var code = ""
    var isLoading = false
    var errorMessage: String?

    /// Returns `true` if verification + API sync worked and view gets dismissed
    func verify(
        clerk: Clerk,
        session: UserSession,
        role: UserRole,
        firstName: String,
        lastName: String,
        email: String,
        phone: String
    ) async -> Bool {
        isLoading = true
        errorMessage = nil
        do {
            guard let signUp = clerk.client?.signUp else {
                isLoading = false
                return false
            }
            try await signUp.verifyEmailCode(code)

            // mark as pending sync so ContentView shows "Creating your account..."
            session.pendingSync = .init(
                role: role.rawValue.lowercased(),
                firstName: firstName,
                lastName: lastName,
                email: email,
                phone: phone.isEmpty ? nil : phone
            )

            // wait for Clerk to establish the session token
            try? await Task.sleep(for: .seconds(1))

            let profile = try await APIClient.shared.syncUser(
                clerk: clerk,
                role: role.rawValue.lowercased(),
                firstName: firstName,
                lastName: lastName,
                email: email,
                phone: phone.isEmpty ? nil : phone
            )

            session.pendingSync = nil
            session.profile = profile
            session.isLoaded = true
            isLoading = false
            return true
        } catch {
            print("verify/sync failed: \(error)")
            // pendingSync already set — don't set isLoaded so ContentView retries
            isLoading = false
            return false
        }
    }
}

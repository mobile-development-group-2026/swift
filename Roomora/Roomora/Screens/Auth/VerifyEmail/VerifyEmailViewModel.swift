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

            _ = try await APIClient.shared.syncUser(
                clerk: clerk,
                role: role.rawValue.lowercased(),
                firstName: firstName,
                lastName: lastName,
                email: email,
                phone: phone.isEmpty ? nil : phone
            )

            isLoading = false
            return true
        } catch {
            errorMessage = error.localizedDescription
            isLoading = false
            return false
        }
    }
}

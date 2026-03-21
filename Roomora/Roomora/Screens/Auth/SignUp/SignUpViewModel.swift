import SwiftUI
import ClerkKit

@Observable
class SignUpViewModel {
    var firstName = ""
    var lastName = ""
    var email = ""
    var phone = ""
    var password = ""
    var role: UserRole = .student
    var agreedToTerms = false
    var isVerifying = false
    var isLoading = false
    var errorMessage: String?

    var buttonTitle: String {
        if isLoading { return "Loading..." }
        return role == .landlord ? "Create Landlord Account" : "Create Account"
    }

    func signUp(clerk: Clerk) async {
        guard agreedToTerms else {
            errorMessage = "Please agree to the Terms of Service and Privacy Policy."
            return
        }
        guard password.count >= 8 else {
            errorMessage = "Password must be at least 8 characters."
            return
        }

        isLoading = true
        errorMessage = nil
        do {
            let signUp = try await clerk.auth.signUp(
                emailAddress: email,
                password: password,
                firstName: firstName,
                lastName: lastName
            )
            try await signUp.sendEmailCode()
            isVerifying = true
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
}

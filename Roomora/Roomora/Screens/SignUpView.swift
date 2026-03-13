import SwiftUI
import ClerkKit

struct SignUpView: View {
    @Environment(Clerk.self) private var clerk
    @Environment(\.dismiss) private var dismiss

    @State private var firstName = ""
    @State private var lastName = ""
    @State private var email = ""
    @State private var password = ""
    @State private var code = ""
    @State private var isVerifying = false
    @State private var isLoading = false
    @State private var errorMessage: String?

    var body: some View {
        ZStack {
            Color(.purple, 900).ignoresSafeArea()

            ScrollView {
                VStack(spacing: AppSpacing.lg) {
                    // Header
                    VStack(spacing: AppSpacing.xs) {
                        Text(isVerifying ? "Verify your email" : "Create your account")
                            .font(.h2())
                            .foregroundStyle(.white)

                        Text(isVerifying
                             ? "Enter the code sent to \(email)"
                             : "Welcome! Please fill in the details to get started.")
                            .font(.body14())
                            .foregroundStyle(Color(.neutral, 500))
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, AppSpacing.xl)

                    if isVerifying {
                        // Verification code input
                        AppTextField(
                            label: "Verification code",
                            placeholder: "Enter code",
                            text: $code
                        )
                        .keyboardType(.numberPad)
                    } else {
                        // Name fields
                        HStack(spacing: AppSpacing.sm) {
                            AppTextField(
                                label: "First name",
                                placeholder: "First name",
                                text: $firstName
                            )
                            AppTextField(
                                label: "Last name",
                                placeholder: "Last name",
                                text: $lastName
                            )
                        }

                        // Email
                        AppTextField(
                            label: "Email address",
                            placeholder: "Enter your email address",
                            text: $email
                        )
                        .keyboardType(.emailAddress)

                        // Password
                        AppTextField(
                            label: "Password",
                            placeholder: "Enter your password",
                            text: $password,
                            isSecure: true
                        )
                    }

                    // Error message
                    if let errorMessage {
                        Text(errorMessage)
                            .font(.body12())
                            .foregroundStyle(Color(.red, 500))
                    }

                    // Submit button
                    AppButton(
                        title: isLoading ? "Loading..." : "Continue",
                        variant: .primary
                    ) {
                        Task {
                            isVerifying ? await verify() : await signUp()
                        }
                    }

                    // Switch to sign in
                    HStack(spacing: AppSpacing.xxs) {
                        Text("Already have an account?")
                            .font(.body14())
                            .foregroundStyle(Color(.neutral, 500))
                        Button("Sign in") {
                            dismiss()
                        }
                        .font(.body14(.semiBold))
                        .foregroundStyle(Color(.purple, 400))
                    }
                }
                .padding(.horizontal, AppSpacing.lg)
            }
        }
    }

    private func signUp() async {
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

    private func verify() async {
        isLoading = true
        errorMessage = nil
        do {
            guard let signUp = clerk.client?.signUp else { return }
            try await signUp.verifyEmailCode(code)
            dismiss()
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
}

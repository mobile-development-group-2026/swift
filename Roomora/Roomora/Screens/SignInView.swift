import SwiftUI
import ClerkKit

struct SignInView: View {
    @Environment(Clerk.self) private var clerk
    @Environment(\.dismiss) private var dismiss

    @State private var email = ""
    @State private var password = ""
    @State private var isLoading = false
    @State private var errorMessage: String?

    var body: some View {
        ZStack {
            Color(.purple, 900).ignoresSafeArea()

            ScrollView {
                VStack(spacing: AppSpacing.lg) {
                    // Header
                    VStack(spacing: AppSpacing.xs) {
                        Text("Welcome back")
                            .font(.h2())
                            .foregroundStyle(.white)

                        Text("Sign in to your account")
                            .font(.body14())
                            .foregroundStyle(Color(.neutral, 500))
                    }
                    .padding(.top, AppSpacing.xl)

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
                        Task { await signIn() }
                    }

                    // Switch to sign up
                    HStack(spacing: AppSpacing.xxs) {
                        Text("Don't have an account?")
                            .font(.body14())
                            .foregroundStyle(Color(.neutral, 500))
                        Button("Sign up") {
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

    private func signIn() async {
        isLoading = true
        errorMessage = nil
        do {
            let signIn = try await clerk.auth.signInWithPassword(
                identifier: email,
                password: password
            )
            if signIn.status == .complete {
                dismiss()
            }
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
}

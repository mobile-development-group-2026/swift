import SwiftUI
import ClerkKit

struct SignInView: View {
    @Environment(Clerk.self) private var clerk
    @Environment(\.dismiss) private var dismiss

    @State private var email = ""
    @State private var password = ""
    @State private var showPassword = false
    @State private var isLoading = false
    @State private var errorMessage: String?

    var body: some View {
        VStack(spacing: AppSpacing.lg) {
            // Drag indicator
            Capsule()
                .fill(Color(.neutral, 400))
                .frame(width: 40, height: 4)
                .padding(.top, AppSpacing.sm)

            ScrollView {
                VStack(spacing: AppSpacing.lg) {
                    // Header
                    VStack(alignment: .leading, spacing: AppSpacing.xs) {
                        HStack(spacing: AppSpacing.xs) {
                            Text("Welcome")
                                .font(.h2(.bold))
                                .foregroundStyle(Color(.neutral, 900))
                            Text("back")
                                .font(.h2(.bold))
                                .foregroundStyle(Color(.purple, 500))
                        }

                        Text("Sign in to continue finding your perfect place.")
                            .font(.body14())
                            .foregroundStyle(Color(.neutral, 600))
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)

                    // Social proof
                    HStack(spacing: AppSpacing.xs) {
                        HStack(spacing: -8) {
                            ForEach(["M", "L", "A", "+"], id: \.self) { letter in
                                Circle()
                                    .fill(Color(.purple, 300))
                                    .frame(width: 28, height: 28)
                                    .overlay(
                                        Text(letter)
                                            .font(.body10(.semiBold))
                                            .foregroundStyle(Color(.purple, 800))
                                    )
                                    .overlay(
                                        Circle()
                                            .stroke(.white, lineWidth: 2)
                                    )
                            }
                        }

                        Text("**2,400+ students** found housing\nthrough Roomora this semester")
                            .font(.body12())
                            .foregroundStyle(Color(.neutral, 600))
                    }

                    // Email field
                    VStack(alignment: .leading, spacing: AppSpacing.xs) {
                        Text("EMAIL ADDRESS")
                            .font(.body10(.semiBold))
                            .foregroundStyle(Color(.neutral, 700))

                        HStack(spacing: AppSpacing.sm) {
                            Image(systemName: "envelope")
                                .foregroundStyle(Color(.neutral, 500))
                                .font(.body16())
                            TextField("", text: $email, prompt: Text("you@university.edu").foregroundColor(Color(.neutral, 500)))
                                .font(.body16())
                                .foregroundStyle(Color(.neutral, 900))
                                .keyboardType(.emailAddress)
                                .autocorrectionDisabled()
                                .textInputAutocapitalization(.never)
                        }
                        .padding(AppSpacing.md)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color(.neutral, 300), lineWidth: 1)
                        )
                    }

                    // Password field
                    VStack(alignment: .leading, spacing: AppSpacing.xs) {
                        Text("PASSWORD")
                            .font(.body10(.semiBold))
                            .foregroundStyle(Color(.neutral, 700))

                        HStack(spacing: AppSpacing.sm) {
                            Image(systemName: "lock")
                                .foregroundStyle(Color(.neutral, 500))
                                .font(.body16())

                            Group {
                                if showPassword {
                                    TextField("", text: $password, prompt: Text("Enter your password").foregroundColor(Color(.neutral, 500)))
                                } else {
                                    SecureField("", text: $password, prompt: Text("Enter your password").foregroundColor(Color(.neutral, 500)))
                                }
                            }
                            .font(.body16())
                            .foregroundStyle(Color(.neutral, 900))
                            .autocorrectionDisabled()
                            .textInputAutocapitalization(.never)

                            Button {
                                showPassword.toggle()
                            } label: {
                                Image(systemName: showPassword ? "eye.slash" : "eye")
                                    .foregroundStyle(Color(.neutral, 500))
                                    .font(.body16())
                            }
                        }
                        .padding(AppSpacing.md)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color(.neutral, 300), lineWidth: 1)
                        )

                        HStack {
                            Spacer()
                            Button("Forgot password?") {}
                                .font(.body14(.semiBold))
                                .foregroundStyle(Color(.purple, 500))
                        }
                    }

                    // Error message
                    if let errorMessage {
                        Text(errorMessage)
                            .font(.body12())
                            .foregroundStyle(Color(.red, 500))
                    }

                    // Sign In button
                    AppButton(
                        title: isLoading ? "Signing in..." : "Sign In  →",
                        variant: .primary
                    ) {
                        Task { await signIn() }
                    }

                    // Sign up link
                    HStack(spacing: AppSpacing.xxs) {
                        Text("Don't have an account?")
                            .font(.body14())
                            .foregroundStyle(Color(.neutral, 500))
                        Button("Sign up free") {
                            dismiss()
                        }
                        .font(.body14(.semiBold))
                        .foregroundStyle(Color(.purple, 500))
                    }
                }
                .padding(.horizontal, AppSpacing.lg)
            }
        }
        .background(.white)
        .tint(Color(.neutral, 900))
        .onTapGesture {
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
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

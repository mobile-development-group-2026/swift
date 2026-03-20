import SwiftUI
import ClerkKit

struct SignInView: View {
    @Environment(Clerk.self) private var clerk
    @Environment(UserSession.self) private var session
    @Environment(\.dismiss) private var dismiss

    @State private var vm = SignInViewModel()

    var body: some View {
        VStack(spacing: AppSpacing.lg) {
            // drag thingy
            Capsule()
                .fill(Color(.neutral, 400))
                .frame(width: 40, height: 4)
                .padding(.top, AppSpacing.sm)

            ScrollView {
                VStack(spacing: AppSpacing.lg) {
                    // header
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

                    // social proof
                    HStack(spacing: AppSpacing.xs) {
                        HStack(spacing: -8) {
                            // this is just random lol
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

                    // email
                    AppTextField(
                        icon: "envelope",
                        label: "EMAIL ADDRESS",
                        placeholder: "you@university.edu",
                        text: $vm.email,
                        keyboardType: .emailAddress
                    )

                    // password
                    VStack(alignment: .leading, spacing: AppSpacing.xs) {
                        AppTextField(
                            icon: "lock",
                            label: "PASSWORD",
                            placeholder: "Enter your password",
                            text: $vm.password,
                            isSecure: true
                        )

                        HStack {
                            Spacer()
                            Button("Forgot password?") {}
                                .font(.body14(.semiBold))
                                .foregroundStyle(Color(.purple, 500))
                        }
                    }

                    ErrorMessage(message: vm.errorMessage)

                    // sign-in
                    AppButton(
                        title: vm.buttonTitle,
                        variant: .primary
                    ) {
                        Task {
                            if await vm.signIn(clerk: clerk, session: session) {
                                dismiss()
                            }
                        }
                    }

                    // sign-up
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
        .dismissKeyboardOnTap()
    }
}

#Preview {
    NavigationStack {
        SignInView()
            .environment(AppRouter())
            .environment(Clerk.shared)
    }
}

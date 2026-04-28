import SwiftUI
import ClerkKit

struct SignUpView: View {
    @Environment(Clerk.self) private var clerk
    @Environment(AppRouter.self) private var router
    @Environment(\.dismiss) private var dismiss

    @State private var vm = SignUpViewModel()

    var body: some View {
        VStack(spacing: 0) {
            // logo
            HStack(spacing: AppSpacing.xs) {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color(.purple, 600))
                    .frame(width: 32, height: 32)
                    .overlay(
                        Image(systemName: "house.fill")
                            .font(.system(size: 14))
                            .foregroundStyle(.white)
                    )
                Text("roomora")
                    .font(.h4(.bold))
                    .foregroundStyle(Color(.neutral, 900))
            }

            // nav bar
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Log in") {
                        router.pop()
                        router.present(.signIn, style: .sheet)
                    }
                    .font(.body14(.semiBold))
                    .foregroundStyle(Color(.purple, 500))
                }
            }
            .padding(.vertical, AppSpacing.sm)

            ScrollView {
                VStack(alignment: .leading, spacing: AppSpacing.lg) {

                    if vm.isVerifying {
                        VerifyEmailView(
                            email: vm.email,
                            role: vm.role,
                            firstName: vm.firstName,
                            lastName: vm.lastName,
                            phone: vm.phone
                        )
                        .environment(clerk)
                    } else {
                        // header
                        VStack(alignment: .leading, spacing: AppSpacing.xs) {
                            Text("Create your")
                                .font(.h1())
                                .foregroundStyle(Color(.neutral, 900))
                            Text("account")
                                .font(.h1())
                                .foregroundStyle(Color(.purple, 500))
                            Text(vm.role == .student
                                 ? "Join thousands of students finding their perfect home."
                                 : "Reach thousands of verified students looking for housing near campus.")
                                .font(.body14())
                                .foregroundStyle(Color(.neutral, 600))
                                .padding(.top, AppSpacing.xxs)
                        }

                        RolePicker(role: $vm.role)

                        // name
                        HStack(spacing: AppSpacing.sm) {
                            AppTextField(
                                icon: "person",
                                label: "FIRST NAME",
                                placeholder: "Carla",
                                text: $vm.firstName
                            )

                            AppTextField(
                                icon: "person",
                                label: "LAST NAME",
                                placeholder: "García",
                                text: $vm.lastName
                            )
                        }

                        // email
                        AppTextField(
                            icon: "envelope",
                            label: "EMAIL ADDRESS",
                            placeholder: vm.role == .student ? "you@university.edu" : "lena@email.com",
                            text: $vm.email,
                            keyboardType: .emailAddress
                        )

                        // phone number (landlord only)
                        if vm.role == .landlord {
                            PhoneField(
                                label: "PHONE NUMBER",
                                phone: $vm.phone
                            )
                            .transition(.move(edge: .top).combined(with: .opacity))

                            // id verification info
                            HStack(alignment: .top, spacing: AppSpacing.sm) {
                                Image(systemName: "checkmark.shield")
                                    .foregroundStyle(Color(.purple, 500))
                                    .font(.body16())

                                Text("**Identity verification required.** After signup you'll verify your ID and ownership documents to list properties on Roomora.")
                                    .font(.body14())
                                    .foregroundStyle(Color(.purple, 800))
                            }
                            .padding(AppSpacing.md)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color(.purple, 100))
                            )
                            .transition(.move(edge: .top).combined(with: .opacity))
                        }

                        // password
                        VStack(alignment: .leading, spacing: AppSpacing.xs) {
                            AppTextField(
                                icon: "lock",
                                label: "PASSWORD",
                                placeholder: "Min. 8 characters",
                                text: $vm.password,
                                isSecure: true
                            )

                            PasswordStrengthBar(password: vm.password)
                        }

                        // terms checkbox
                        Button {
                            vm.agreedToTerms.toggle()
                        } label: {
                            HStack(spacing: AppSpacing.sm) {
                                Image(systemName: vm.agreedToTerms ? "checkmark.square.fill" : "square")
                                    .foregroundStyle(vm.agreedToTerms ? Color(.purple, 500) : Color(.neutral, 500))
                                    .font(.body18())

                                Text("I agree to the [Terms of Service](terms) and [Privacy Policy](privacy)")
                                    .font(.body12())
                                    .foregroundStyle(Color(.neutral, 600))
                                    .tint(Color(.purple, 500))
                            }
                        }
                    }

                    if !vm.isVerifying {
                        ErrorMessage(message: vm.errorMessage)

                        Spacer(minLength: AppSpacing.xl)

                        // create Account button
                        AppButton(
                            title: vm.buttonTitle,
                            variant: .primary
                        ) {
                            Task { await vm.signUp(clerk: clerk) }
                        }
                    }
                }
                .padding(.horizontal, AppSpacing.lg)
                .padding(.top, AppSpacing.md)
            }
            .scrollDismissesKeyboard(.interactively)
        }
        .background(.white)
        .tint(Color(.neutral, 900))
    }
}


#Preview {
    NavigationStack {
        SignUpView()
            .environment(AppRouter())
            .environment(Clerk.shared)
    }
}

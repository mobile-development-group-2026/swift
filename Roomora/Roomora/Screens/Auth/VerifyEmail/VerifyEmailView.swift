import SwiftUI
import ClerkKit

struct VerifyEmailView: View {
    @Environment(Clerk.self) private var clerk
    @Environment(\.dismiss) private var dismiss

    let email: String
    let role: UserRole
    let firstName: String
    let lastName: String
    let phone: String

    @State private var vm = VerifyEmailViewModel()

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.lg) {
            VStack(alignment: .leading, spacing: AppSpacing.xs) {
                Text("Verify your")
                    .font(.h1())
                    .foregroundStyle(Color(.neutral, 900))
                Text("email")
                    .font(.h1())
                    .foregroundStyle(Color(.purple, 500))
                Text("Enter the code sent to \(email)")
                    .font(.body14())
                    .foregroundStyle(Color(.neutral, 600))
                    .padding(.top, AppSpacing.xxs)
            }

            AppTextField(
                icon: "number",
                label: "VERIFICATION CODE",
                placeholder: "Enter code",
                text: $vm.code,
                keyboardType: .numberPad
            )

            ErrorMessage(message: vm.errorMessage)

            Spacer(minLength: AppSpacing.xl)

            AppButton(
                title: vm.isLoading ? "Loading..." : "Verify Email",
                variant: .primary
            ) {
                Task {
                    if await vm.verify(
                        clerk: clerk,
                        role: role,
                        firstName: firstName,
                        lastName: lastName,
                        email: email,
                        phone: phone
                    ) {
                        dismiss()
                    }
                }
            }
        }
    }
}

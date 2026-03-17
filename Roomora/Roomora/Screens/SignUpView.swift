import SwiftUI
import ClerkKit

enum UserRole: String, CaseIterable {
    case student = "Student"
    case landlord = "Landlord"

    var icon: String {
        switch self {
        case .student: return "🎓"
        case .landlord: return "🏠"
        }
    }
}

struct SignUpView: View {
    @Environment(Clerk.self) private var clerk
    @Environment(\.dismiss) private var dismiss

    @State private var firstName = ""
    @State private var lastName = ""
    @State private var email = ""
    @State private var phone = ""
    @State private var password = ""
    @State private var role: UserRole = .student
    @State private var agreedToTerms = false
    @State private var code = ""
    @State private var isVerifying = false
    @State private var isLoading = false
    @State private var errorMessage: String?

    var body: some View {
        VStack(spacing: 0) {
            // Nav bar
            HStack {
                Button {
                    if isVerifying {
                        isVerifying = false
                    } else {
                        dismiss()
                    }
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.body18())
                        .foregroundStyle(Color(.neutral, 800))
                        .frame(width: 40, height: 40)
                        .background(
                            Circle()
                                .stroke(Color(.neutral, 300), lineWidth: 1)
                        )
                }

                Spacer()

                // Logo
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

                Spacer()

                Button("Log in") {
                    dismiss()
                }
                .font(.body14(.semiBold))
                .foregroundStyle(Color(.purple, 500))
            }
            .padding(.horizontal, AppSpacing.lg)
            .padding(.vertical, AppSpacing.sm)

            ScrollView {
                VStack(alignment: .leading, spacing: AppSpacing.lg) {

                    if isVerifying {
                        // Verification view
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

                        VStack(alignment: .leading, spacing: AppSpacing.xs) {
                            Text("VERIFICATION CODE")
                                .font(.body10(.semiBold))
                                .foregroundStyle(Color(.neutral, 700))

                            HStack(spacing: AppSpacing.sm) {
                                Image(systemName: "number")
                                    .foregroundStyle(Color(.neutral, 500))
                                    .font(.body16())
                                TextField("Enter code", text: $code)
                                    .font(.body16())
                                    .keyboardType(.numberPad)
                            }
                            .padding(AppSpacing.md)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color(.neutral, 300), lineWidth: 1)
                            )
                        }

                    } else {
                        // Header
                        VStack(alignment: .leading, spacing: AppSpacing.xs) {
                            Text("Create your")
                                .font(.h1())
                                .foregroundStyle(Color(.neutral, 900))
                            Text("account")
                                .font(.h1())
                                .foregroundStyle(Color(.purple, 500))
                            Text(role == .student
                                 ? "Join thousands of students finding their perfect home."
                                 : "Reach thousands of verified students looking for housing near campus.")
                                .font(.body14())
                                .foregroundStyle(Color(.neutral, 600))
                                .padding(.top, AppSpacing.xxs)
                        }

                        // Role picker with sliding indicator
                        ZStack(alignment: role == .student ? .leading : .trailing) {
                            // Background
                            RoundedRectangle(cornerRadius: 14)
                                .fill(Color(.neutral, 200))

                            // Sliding white pill
                            RoundedRectangle(cornerRadius: 12)
                                .fill(.white)
                                .shadow(color: Color.black.opacity(0.05), radius: 4)
                                .frame(width: UIScreen.main.bounds.width / 2 - AppSpacing.lg - AppSpacing.xxs)
                                .padding(AppSpacing.xxs)

                            // Labels
                            HStack(spacing: 0) {
                                ForEach(UserRole.allCases, id: \.self) { r in
                                    Button {
                                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                            role = r
                                        }
                                    } label: {
                                        HStack(spacing: AppSpacing.xs) {
                                            Text(r.icon)
                                            Text(r.rawValue)
                                                .font(.body14(.semiBold))
                                        }
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, AppSpacing.sm)
                                        .foregroundStyle(role == r ? Color(.purple, 500) : Color(.neutral, 600))
                                    }
                                }
                            }
                        }
                        .frame(height: 48)

                        // Name fields
                        HStack(spacing: AppSpacing.sm) {
                            VStack(alignment: .leading, spacing: AppSpacing.xs) {
                                Text("FIRST NAME")
                                    .font(.body10(.semiBold))
                                    .foregroundStyle(Color(.neutral, 700))

                                HStack(spacing: AppSpacing.sm) {
                                    Image(systemName: "person")
                                        .foregroundStyle(Color(.neutral, 500))
                                        .font(.body16())
                                    TextField("", text: $firstName, prompt: Text("Carla").foregroundColor(Color(.neutral, 500)))
                                        .font(.body16())
                                        .foregroundStyle(Color(.neutral, 900))
                                }
                                .padding(AppSpacing.md)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color(.neutral, 300), lineWidth: 1)
                                )
                            }

                            VStack(alignment: .leading, spacing: AppSpacing.xs) {
                                Text("LAST NAME")
                                    .font(.body10(.semiBold))
                                    .foregroundStyle(Color(.neutral, 700))

                                HStack(spacing: AppSpacing.sm) {
                                    Image(systemName: "person")
                                        .foregroundStyle(Color(.neutral, 500))
                                        .font(.body16())
                                    TextField("", text: $lastName, prompt: Text("García").foregroundColor(Color(.neutral, 500)))
                                        .font(.body16())
                                        .foregroundStyle(Color(.neutral, 900))
                                }
                                .padding(AppSpacing.md)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color(.neutral, 300), lineWidth: 1)
                                )
                            }
                        }
                        .autocorrectionDisabled()

                        // Email field
                        VStack(alignment: .leading, spacing: AppSpacing.xs) {
                            Text("EMAIL ADDRESS")
                                .font(.body10(.semiBold))
                                .foregroundStyle(Color(.neutral, 700))

                            HStack(spacing: AppSpacing.sm) {
                                Image(systemName: "envelope")
                                    .foregroundStyle(Color(.neutral, 500))
                                    .font(.body16())
                                TextField("", text: $email, prompt: Text(role == .student ? "you@university.edu" : "lena@email.com").foregroundColor(Color(.neutral, 500)))
                                    .font(.body16())
                                    .foregroundStyle(Color(.neutral, 900))
                                    .keyboardType(.emailAddress)
                                    .autocorrectionDisabled()
                                    .textInputAutocapitalization(.never)

                                if role == .landlord {
                                    Text("Required")
                                        .font(.body10())
                                        .foregroundStyle(Color(.neutral, 500))
                                }
                            }
                            .padding(AppSpacing.md)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color(.neutral, 300), lineWidth: 1)
                            )
                        }

                        // Phone number (landlord only)
                        if role == .landlord {
                            VStack(alignment: .leading, spacing: AppSpacing.xs) {
                                Text("PHONE NUMBER")
                                    .font(.body10(.semiBold))
                                    .foregroundStyle(Color(.neutral, 700))

                                HStack(spacing: AppSpacing.sm) {
                                    Image(systemName: "phone")
                                        .foregroundStyle(Color(.neutral, 500))
                                        .font(.body16())
                                    TextField("", text: $phone, prompt: Text("+1 (555) 000-0000").foregroundColor(Color(.neutral, 500)))
                                        .font(.body16())
                                        .foregroundStyle(Color(.neutral, 900))
                                        .keyboardType(.phonePad)

                                    Text("Required")
                                        .font(.body10())
                                        .foregroundStyle(Color(.neutral, 500))
                                }
                                .padding(AppSpacing.md)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color(.neutral, 300), lineWidth: 1)
                                )
                            }
                            .transition(.move(edge: .top).combined(with: .opacity))

                            // Identity verification info
                            HStack(alignment: .top, spacing: AppSpacing.sm) {
                                Image(systemName: "checkmark.shield")
                                    .foregroundStyle(Color(.purple, 500))
                                    .font(.body16())

                                Group {
                                    Text("Identity verification required. ")
                                        .font(.body14(.semiBold))
                                    + Text("After signup you'll verify your ID and ownership documents to list properties on Roomora.")
                                        .font(.body14())
                                }
                                .foregroundStyle(Color(.purple, 800))
                            }
                            .padding(AppSpacing.md)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color(.purple, 100))
                            )
                            .transition(.move(edge: .top).combined(with: .opacity))
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
                                TextField("", text: $password, prompt: Text("Min. 8 characters").foregroundColor(Color(.neutral, 500)))
                                    .font(.body16())
                                    .foregroundStyle(Color(.neutral, 900))
                                    .autocorrectionDisabled()
                                    .textInputAutocapitalization(.never)
                            }
                            .padding(AppSpacing.md)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color(.neutral, 300), lineWidth: 1)
                            )

                            PasswordStrengthBar(password: password)
                        }

                        // Terms checkbox
                        Button {
                            agreedToTerms.toggle()
                        } label: {
                            HStack(spacing: AppSpacing.sm) {
                                Image(systemName: agreedToTerms ? "checkmark.square.fill" : "square")
                                    .foregroundStyle(agreedToTerms ? Color(.purple, 500) : Color(.neutral, 500))
                                    .font(.body18())

                                Group {
                                    Text("I agree to the ")
                                        .foregroundStyle(Color(.neutral, 600))
                                    + Text("Terms of Service")
                                        .foregroundStyle(Color(.purple, 500))
                                    + Text(" and ")
                                        .foregroundStyle(Color(.neutral, 600))
                                    + Text("Privacy Policy")
                                        .foregroundStyle(Color(.purple, 500))
                                }
                                .font(.body12())
                            }
                        }
                    }

                    // Error message
                    if let errorMessage {
                        Text(errorMessage)
                            .font(.body12())
                            .foregroundStyle(Color(.red, 500))
                    }

                    Spacer(minLength: AppSpacing.xl)

                    // Create Account / Verify button
                    AppButton(
                        title: isLoading
                            ? "Loading..."
                            : (isVerifying ? "Verify Email" : (role == .landlord ? "Create Landlord Account" : "Create Account")),
                        variant: .primary
                    ) {
                        Task {
                            isVerifying ? await verify() : await signUp()
                        }
                    }
                }
                .padding(.horizontal, AppSpacing.lg)
                .padding(.top, AppSpacing.md)
            }
        }
        .background(.white)
        .tint(Color(.neutral, 900))
        .onTapGesture {
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        }
    }

    private func signUp() async {
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

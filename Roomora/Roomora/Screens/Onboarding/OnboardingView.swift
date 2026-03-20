import SwiftUI
import ClerkKit

struct OnboardingView: View {
    @Environment(Clerk.self) private var clerk
    @Environment(UserSession.self) private var session

    @State private var vm = OnboardingViewModel()

    var body: some View {
        VStack(spacing: 0) {
            // top bar
            HStack {
                Button {
                    vm.previousStep()
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.body16(.semiBold))
                        .foregroundStyle(Color(.neutral, 700))
                }
                .opacity(vm.step > 0 ? 1 : 0)
                .disabled(vm.step == 0)

                Spacer()

                #if DEBUG
                Button("DEV Reset") {
                    // nuke Clerk keychain data
                    let secItemClasses = [
                        kSecClassGenericPassword,
                        kSecClassInternetPassword
                    ]
                    for itemClass in secItemClasses {
                        SecItemDelete([kSecClass: itemClass] as CFDictionary)
                    }
                    session.clear()
                    // force restart to pick up cleared state
                    exit(0)
                }
                .font(.body12(.semiBold))
                .foregroundStyle(.red)
                #endif
            }
            .padding(.horizontal, AppSpacing.lg)
            .padding(.vertical, AppSpacing.sm)

            // progress bar
            HStack(spacing: AppSpacing.xs) {
                ForEach(0..<vm.totalSteps, id: \.self) { i in
                    RoundedRectangle(cornerRadius: 4)
                        .fill(i <= vm.step ? Color(.purple, 500) : Color(.neutral, 300))
                        .frame(height: 4)
                }
            }
            .padding(.horizontal, AppSpacing.lg)

            // step content
            Group {
                switch vm.step {
                case 0: OnboardingStep1View(vm: vm)
                case 1: OnboardingStep2View(vm: vm)
                case 2: OnboardingStep3View(role: session.role ?? "student")
                default: OnboardingStep4View()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            // error
            if let error = vm.errorMessage {
                Text(error)
                    .font(.body14())
                    .foregroundStyle(.red)
                    .padding(.horizontal, AppSpacing.lg)
            }

            // continue button
            AppButton(
                title: vm.isLastStep
                    ? (vm.isLoading ? "Finishing..." : "Complete Setup")
                    : "Continue  →",
                variant: .primary
            ) {
                if vm.isLastStep {
                    Task { await vm.complete(clerk: clerk, session: session) }
                } else {
                    vm.nextStep()
                }
            }
            .disabled(!vm.canContinue)
            .opacity(vm.canContinue ? 1 : 0.5)
            .padding(.horizontal, AppSpacing.lg)
            .padding(.bottom, AppSpacing.xl)
        }
        .background(.white)
    }
}

#Preview {
    OnboardingView()
        .environment(Clerk.shared)
        .environment(UserSession())
}

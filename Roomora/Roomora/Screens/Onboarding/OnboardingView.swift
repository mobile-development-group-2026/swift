import SwiftUI
import ClerkKit

struct OnboardingView: View {
    @Environment(Clerk.self) private var clerk
    @Environment(UserSession.self) private var session

    @State private var vm = OnboardingViewModel()

    var body: some View {
        VStack(spacing: 0) {
            // progress bar
            HStack(spacing: AppSpacing.xs) {
                ForEach(0..<vm.totalSteps, id: \.self) { i in
                    RoundedRectangle(cornerRadius: 4)
                        .fill(i <= vm.step ? Color(.purple, 500) : Color(.neutral, 300))
                        .frame(height: 4)
                }
            }
            .padding(.horizontal, AppSpacing.lg)
            .padding(.top, AppSpacing.md)

            // step content
            Group {
                switch vm.step {
                case 0: OnboardingStep1View()
                case 1: OnboardingStep2View()
                case 2: OnboardingStep3View()
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

            // buttons
            VStack(spacing: AppSpacing.sm) {
                AppButton(
                    title: vm.isLastStep
                        ? (vm.isLoading ? "Finishing..." : "Complete Setup")
                        : "Next",
                    variant: .primary
                ) {
                    if vm.isLastStep {
                        Task { await vm.complete(clerk: clerk, session: session) }
                    } else {
                        withAnimation { vm.nextStep() }
                    }
                }

                if vm.step > 0 {
                    AppButton(title: "Back", variant: .secondary) {
                        withAnimation { vm.previousStep() }
                    }
                }
            }
            .padding(.horizontal, AppSpacing.lg)
            .padding(.bottom, AppSpacing.xl)
        }
        .background(.white)
    }
}

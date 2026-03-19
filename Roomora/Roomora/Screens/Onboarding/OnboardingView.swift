import SwiftUI
import ClerkKit

struct OnboardingView: View {
    @Environment(Clerk.self) private var clerk
    @Environment(UserSession.self) private var session

    @State private var vm = OnboardingViewModel()

    var body: some View {
        NavigationStack {
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
                .padding(.top, AppSpacing.sm)

                // step content
                Group {
                    switch vm.step {
                    case 0: OnboardingStep1View(vm: vm)
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
                        withAnimation { vm.nextStep() }
                    }
                }
                .padding(.horizontal, AppSpacing.lg)
                .padding(.bottom, AppSpacing.xl)
            }
            .background(.white)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    if vm.step > 0 {
                        Button {
                            withAnimation { vm.previousStep() }
                        } label: {
                            Image(systemName: "chevron.left")
                                .font(.body16(.semiBold))
                                .foregroundStyle(Color(.neutral, 700))
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    OnboardingView()
        .environment(Clerk.shared)
        .environment(UserSession())
}

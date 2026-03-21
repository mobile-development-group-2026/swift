import SwiftUI
import ClerkKit

struct OnboardingView: View {
    @Environment(Clerk.self) private var clerk
    @Environment(UserSession.self) private var session

    @State private var vm = OnboardingViewModel()

    var body: some View {
        if vm.showCelebration {
            OnboardingCompleteView(
                firstName: session.firstName ?? "there",
                role: session.role ?? "student"
            ) {
                vm.finishOnboarding(session: session)
            }
        } else {
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
                case 0: BuildYourProfileView(vm: vm.buildProfile, role: session.role ?? "student")
                case 1: RoommateSituationView(vm: vm.situation)
                default:
                    if vm.needsPlace {
                        ListingPreferencesView(vm: vm.listingPrefs)
                    } else {
                        RoommatePreferencesView(vm: vm.preferences, role: session.role ?? "student")
                    }
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
                Task {
                    if vm.isLastStep {
                        await vm.complete(clerk: clerk)
                    } else {
                        await vm.nextStep(clerk: clerk, role: session.role ?? "student")
                    }
                }
            }
            .disabled(!vm.canContinue)
            .opacity(vm.canContinue ? 1 : 0.5)
            .padding(.horizontal, AppSpacing.lg)
            .padding(.vertical, AppSpacing.lg)
        }
        .background(.white)
        }
    }
}

#Preview {
    OnboardingView()
        .environment(Clerk.shared)
        .environment(UserSession())
}

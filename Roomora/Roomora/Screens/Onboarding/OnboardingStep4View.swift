import SwiftUI

struct OnboardingStep4View: View {
    var body: some View {
        VStack(spacing: AppSpacing.md) {
            Text("🎉")
                .font(.system(size: 48))
            Text("Finish Up")
                .font(.h2(.bold))
                .foregroundStyle(Color(.neutral, 900))
            Text("You're almost ready to go!")
                .font(.body16())
                .foregroundStyle(Color(.neutral, 500))
        }
        .padding(AppSpacing.lg)
    }
}

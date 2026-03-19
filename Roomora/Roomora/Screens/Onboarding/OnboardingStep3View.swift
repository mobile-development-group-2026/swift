import SwiftUI

struct OnboardingStep3View: View {
    var body: some View {
        VStack(spacing: AppSpacing.md) {
            Text("⚙️")
                .font(.system(size: 48))
            Text("Preferences")
                .font(.h2(.bold))
                .foregroundStyle(Color(.neutral, 900))
            Text("Budget, move-in date, and living style.")
                .font(.body16())
                .foregroundStyle(Color(.neutral, 500))
        }
        .padding(AppSpacing.lg)
    }
}

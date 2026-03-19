import SwiftUI

struct OnboardingStep1View: View {
    var body: some View {
        VStack(spacing: AppSpacing.md) {
            Text("🏠")
                .font(.system(size: 48))
            Text("Profile Basics")
                .font(.h2(.bold))
                .foregroundStyle(Color(.neutral, 900))
            Text("University, bio, and the essentials.")
                .font(.body16())
                .foregroundStyle(Color(.neutral, 500))
        }
        .padding(AppSpacing.lg)
    }
}

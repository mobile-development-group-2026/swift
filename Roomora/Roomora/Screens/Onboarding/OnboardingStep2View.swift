import SwiftUI

struct OnboardingStep2View: View {
    var body: some View {
        VStack(spacing: AppSpacing.md) {
            Text("👤")
                .font(.system(size: 48))
            Text("About You")
                .font(.h2(.bold))
                .foregroundStyle(Color(.neutral, 900))
            Text("Tell us a bit more about yourself.")
                .font(.body16())
                .foregroundStyle(Color(.neutral, 500))
        }
        .padding(AppSpacing.lg)
    }
}

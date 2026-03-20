import SwiftUI

struct PreferenceSection<Content: View>: View {
    let icon: String
    let title: String
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            HStack(spacing: AppSpacing.xs) {
                Image(systemName: icon)
                    .font(.body12())
                    .foregroundStyle(Color(.purple, 500))
                Text(title)
                    .font(.body10(.semiBold))
                    .foregroundStyle(Color(.neutral, 700))
            }

            content
        }
    }
}

import SwiftUI

struct HintBanner: View {
    let message: AttributedString

    var body: some View {
        HStack(spacing: AppSpacing.sm) {
            Image(systemName: "info.circle")
                .font(.body14())
                .foregroundStyle(Color(.yellow, 700))

            Text(message)
                .font(.body14())
                .foregroundStyle(Color(.yellow, 800))
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(AppSpacing.md)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.yellow, 100))
        )
    }
}

import SwiftUI

struct PillBadge: View {
    let label: String
    var dotColor: Color = Color(.purple, 500)

    var body: some View {
        HStack(spacing: 8) {
            Circle()
                .fill(dotColor)
                .frame(width: 8, height: 8)

            Text(label)
                .font(.body12())
                .foregroundStyle(.white)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(
            Capsule()
                .stroke(.white.opacity(0.2), lineWidth: 1)
        )
    }
}

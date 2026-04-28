import SwiftUI

struct RolePicker: View {
    @Binding var role: UserRole

    var body: some View {
        ZStack {
            // background
            RoundedRectangle(cornerRadius: 14)
                .fill(Color(.neutral, 200))

            // sliding white pill
            HStack(spacing: 0) {
                if role != .student { Color.clear }
                RoundedRectangle(cornerRadius: 12)
                    .fill(.white)
                    .shadow(color: Color.black.opacity(0.05), radius: 4)
                if role == .student { Color.clear }
            }
            .padding(AppSpacing.xxs)

            // labels
            HStack(spacing: 0) {
                roleButton(.student)
                roleButton(.landlord)
            }
        }
        .frame(height: 48)
    }

    private func roleButton(_ r: UserRole) -> some View {
        Button {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                role = r
            }
        } label: {
            HStack(spacing: AppSpacing.xs) {
                Text(r.icon)
                Text(r.rawValue)
                    .font(.body14(.semiBold))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, AppSpacing.sm)
            .foregroundStyle(role == r ? Color(.purple, 500) : Color(.neutral, 600))
        }
    }
}

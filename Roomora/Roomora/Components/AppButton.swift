import SwiftUI

enum ButtomVariants {
    case primary
    case secondary
}

struct AppButton: View {
    let title: String
    var variant: ButtomVariants = .primary
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.h4)
                .foregroundStyle(AppColors.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    RoundedRectangle(cornerRadius: 14)
                        .fill(variant == .primary ? AppColors.purple500 : Color.clear)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(
                            variant == .secondary ? AppColors.purple500 : Color.clear,
                            lineWidth: 1.5
                        )
                )
        }
    }
}

import SwiftUI

enum ButtonVariants {
    case primary
    case secondary
}

struct AppButton: View {
    let title: String
    var variant: ButtonVariants = .primary
    let action: () -> Void

    // visual components of button
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.body18(.semiBold))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    RoundedRectangle(cornerRadius: 14)
                        .fill(variant == .primary ? Color(.purple, 500) : Color.clear)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(
                            variant == .secondary ? Color(.purple, 500) : Color.clear,
                            lineWidth: 1.5
                        )
                )
        }
    }
}

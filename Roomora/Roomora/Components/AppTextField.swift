import SwiftUI

struct AppTextField: View {
    let label: String
    let placeholder: String
    @Binding var text: String
    var isSecure: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.xs) {
            Text(label)
                .font(.body14(.semiBold))
                .foregroundStyle(.white)

            Group {
                if isSecure {
                    SecureField(placeholder, text: $text)
                } else {
                    TextField(placeholder, text: $text)
                }
            }
            .font(.body16())
            .padding(AppSpacing.md)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.neutral, 900))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color(.neutral, 700), lineWidth: 1)
            )
            .foregroundStyle(.white)
            .autocorrectionDisabled()
            .textInputAutocapitalization(.never)
        }
    }
}

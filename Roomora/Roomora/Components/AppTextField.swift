import SwiftUI

struct AppTextField: View {
    let icon: String
    let label: String
    let placeholder: String
    @Binding var text: String
    var isSecure: Bool = false
    var isMultiline: Bool = false
    var minHeight: CGFloat = 0
    var keyboardType: UIKeyboardType = .default

    @State private var showPassword = false

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.xs) {
            Text(label)
                .font(.body10(.semiBold))
                .foregroundStyle(Color(.neutral, 700))

            if isMultiline {
                ZStack(alignment: .topLeading) {
                    TextEditor(text: $text)
                        .font(.body16())
                        .foregroundStyle(Color(.neutral, 900))
                        .scrollContentBackground(.hidden)
                        .frame(minHeight: minHeight > 0 ? minHeight : 120)

                    if text.isEmpty {
                        Text(placeholder)
                            .font(.body16())
                            .foregroundStyle(Color(.neutral, 500))
                            .padding(.top, 8)
                            .padding(.leading, 4)
                            .allowsHitTesting(false)
                    }
                }
                .padding(AppSpacing.md)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color(.neutral, 500), lineWidth: 1)
                )
            } else {
                HStack(spacing: AppSpacing.sm) {
                    Image(systemName: icon)
                        .foregroundStyle(Color(.neutral, 500))
                        .font(.body16())

                    Group {
                        if isSecure && !showPassword {
                            SecureField("", text: $text, prompt: Text(placeholder).foregroundColor(Color(.neutral, 500)))
                        } else {
                            TextField("", text: $text, prompt: Text(placeholder).foregroundColor(Color(.neutral, 500)))
                        }
                    }
                    .font(.body16())
                    .foregroundStyle(Color(.neutral, 900))
                    .keyboardType(keyboardType)
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.never)

                    if isSecure {
                        Button {
                            showPassword.toggle()
                        } label: {
                            Image(systemName: showPassword ? "eye.slash" : "eye")
                                .foregroundStyle(Color(.neutral, 500))
                                .font(.body16())
                        }
                    }
                }
                .padding(AppSpacing.md)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color(.neutral, 500), lineWidth: 1)
                )
            }
        }
    }
}

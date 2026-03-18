import SwiftUI

struct AppTextField<Trailing: View>: View {
    let icon: String
    let label: String
    let placeholder: String
    @Binding var text: String
    var isSecure: Bool = false
    var keyboardType: UIKeyboardType = .default
    @ViewBuilder var trailing: () -> Trailing

    @State private var showPassword = false

    init(
        icon: String,
        label: String,
        placeholder: String,
        text: Binding<String>,
        isSecure: Bool = false,
        keyboardType: UIKeyboardType = .default,
        @ViewBuilder trailing: @escaping () -> Trailing = { EmptyView() }
    ) {
        self.icon = icon
        self.label = label
        self.placeholder = placeholder
        self._text = text
        self.isSecure = isSecure
        self.keyboardType = keyboardType
        self.trailing = trailing
    }

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.xs) {
            Text(label)
                .font(.body10(.semiBold))
                .foregroundStyle(Color(.neutral, 700))

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

                trailing()
            }
            .padding(AppSpacing.md)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color(.neutral, 300), lineWidth: 1)
            )
        }
    }
}

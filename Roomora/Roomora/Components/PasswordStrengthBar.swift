import SwiftUI

struct PasswordStrengthBar: View {
    let password: String

    private var strength: Int {
        var score = 0
        if password.count >= 4 { score += 1 }
        if password.count >= 6 { score += 1 }
        if password.count >= 8 { score += 1 }
        if password.count >= 8 && password.rangeOfCharacter(from: .uppercaseLetters) != nil
            && password.rangeOfCharacter(from: .decimalDigits) != nil { score += 1 }
        return score
    }

    private var color: Color {
        switch strength {
        case 1: return Color(.red, 500)
        case 2: return Color(.yellow, 500)
        case 3: return Color(.yellow, 500)
        case 4: return Color(.green, 500)
        default: return Color(.neutral, 300)
        }
    }

    var body: some View {
        HStack(spacing: AppSpacing.xxs) {
            ForEach(0..<4, id: \.self) { i in
                RoundedRectangle(cornerRadius: 2)
                    .fill(i < strength ? color : Color(.neutral, 300))
                    .frame(height: 4)
            }
        }
        .animation(.easeInOut(duration: 0.2), value: strength)
    }
}

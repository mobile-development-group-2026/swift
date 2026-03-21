import SwiftUI

struct ErrorMessage: View {
    let message: String?

    var body: some View {
        if let message {
            Text(message)
                .font(.body12())
                .foregroundStyle(Color(.red, 500))
        }
    }
}

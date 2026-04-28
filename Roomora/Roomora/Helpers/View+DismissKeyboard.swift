import SwiftUI

extension View {
    /// Dismisses keyboard when user taps outside of a text field.
    /// Uses a background layer so it doesn't intercept Button taps.
    func dismissKeyboardOnTap() -> some View {
        self.background {
            Color.clear
                .contentShape(Rectangle())
                .onTapGesture {
                    UIApplication.shared.sendAction(
                        #selector(UIResponder.resignFirstResponder),
                        to: nil, from: nil, for: nil
                    )
                }
        }
    }
}

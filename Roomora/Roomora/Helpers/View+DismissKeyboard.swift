import SwiftUI

extension View {
    /// Dismisses  keyboard when  user taps outside of a text field. (I got this snippet from Claude)
    func dismissKeyboardOnTap() -> some View {
        self.contentShape(Rectangle())
            .simultaneousGesture(
                TapGesture().onEnded {
                    UIApplication.shared.sendAction(
                        #selector(UIResponder.resignFirstResponder),
                        to: nil, from: nil, for: nil
                    )
                }
            )
    }
}

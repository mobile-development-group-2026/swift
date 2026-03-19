import SwiftUI

extension View {
    /// Dismisses  keyboard when  user taps outside of a text field. (I got this snippet from Claude and it worked)
    func dismissKeyboardOnTap() -> some View {
        self.onTapGesture {
            UIApplication.shared.sendAction(
                #selector(UIResponder.resignFirstResponder),
                to: nil, from: nil, for: nil
            )
        }
    }
}

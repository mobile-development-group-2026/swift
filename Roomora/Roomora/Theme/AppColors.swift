import SwiftUI

enum AppHue: String {
    case purple = "Purple"
    case green = "Green"
    case yellow = "Yellow"
    case red = "Red"
    case neutral = "Neutral"
}

extension Color {
    init(_ hue: AppHue, _ value: Int) {
        // this constructs the string "purple500" and it looks for this in the assets we defined
        self.init("\(hue.rawValue)\(value)")
    }
}

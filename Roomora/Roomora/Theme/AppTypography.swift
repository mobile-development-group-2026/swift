import SwiftUI


//
enum AppFont {
    enum Weight: String {
        case thin = "Sora-Thin"
        case extraLight = "Sora-ExtraLight"
        case light = "Sora-Light"
        case regular = "Sora-Regular"
        case medium = "Sora-Medium"
        case semiBold = "Sora-SemiBold"
        case bold = "Sora-Bold"
        case extraBold = "Sora-ExtraBold"
    }

    static func custom(_ weight: Weight, size: CGFloat) -> Font {
        .custom(weight.rawValue, size: size)
    }
}

extension Font {
    // Headings
    static let h1 = AppFont.custom(.bold, size: 36)
    static let h2 = AppFont.custom(.semiBold, size: 28)
    static let h3 = AppFont.custom(.semiBold, size: 24)
    static let h4 = AppFont.custom(.medium, size: 20)

    // Body
    static let body18 = AppFont.custom(.regular, size: 18)
    static let body16 = AppFont.custom(.regular, size: 16)
    static let body14 = AppFont.custom(.regular, size: 14)
    static let body12 = AppFont.custom(.regular, size: 12)
    static let body10 = AppFont.custom(.regular, size: 10)
}

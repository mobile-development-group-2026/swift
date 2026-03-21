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

// extends Apple's Font type
extension Font {
    // headings
    static let h1 = AppFont.custom(.bold, size: 36)
    static let h2 = AppFont.custom(.semiBold, size: 28)
    static let h3 = AppFont.custom(.semiBold, size: 24)
    static let h4 = AppFont.custom(.medium, size: 20)

    // body
    static func body18(_ weight: AppFont.Weight = .regular) -> Font {
        AppFont.custom(weight, size: 18)
    }
    static func body16(_ weight: AppFont.Weight = .regular) -> Font {
        AppFont.custom(weight, size: 16)
    }
    static func body14(_ weight: AppFont.Weight = .regular) -> Font {
        AppFont.custom(weight, size: 14)
    }
    static func body12(_ weight: AppFont.Weight = .regular) -> Font {
        AppFont.custom(weight, size: 12)
    }
    static func body10(_ weight: AppFont.Weight = .regular) -> Font {
        AppFont.custom(weight, size: 10)
    }
}

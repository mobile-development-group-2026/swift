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
    static func h1(_ weight: AppFont.Weight = .bold) -> Font {
        AppFont.custom(weight, size: 36)
    }
    static func h2(_ weight: AppFont.Weight = .semiBold) -> Font {
        AppFont.custom(weight, size: 28)
    }
    static func h3(_ weight: AppFont.Weight = .semiBold) -> Font {
        AppFont.custom(weight, size: 24)
    }
    static func h4(_ weight: AppFont.Weight = .medium) -> Font {
        AppFont.custom(weight, size: 20)
    }

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

import UIKit

public extension UIColor {
    convenience init(hex: Int, alpha: Double = 1) {
        self.init(
            red: Double((hex >> 16) & 0xff) / 255,
            green: Double((hex >> 08) & 0xff) / 255,
            blue: Double((hex >> 00) & 0xff) / 255,
            alpha: alpha
        )
    }

    static func dynamic(light: UIColor, dark: UIColor) -> UIColor {
        UIColor { traits in
            switch traits.userInterfaceStyle {
            case .dark:
                return dark
            default:
                return light
            }
        }
    }
}

public extension UIColor {
    static let primary50 = UIColor.dynamic(
        light: ColorPalette.primary50Light,
        dark: ColorPalette.primary50Dark
    )
    static let primary100 = UIColor.dynamic(
        light: ColorPalette.primary100Light,
        dark: ColorPalette.primary100Dark
    )
    static let primary500 = UIColor.dynamic(
        light: ColorPalette.primary500Light,
        dark: ColorPalette.primary500Dark
    )
    static let primary700 = UIColor.dynamic(
        light: ColorPalette.primary700Light,
        dark: ColorPalette.primary700Dark
    )
    static let neutral0 = UIColor.dynamic(
        light: ColorPalette.neutral0Light,
        dark: ColorPalette.neutral0Dark
    )
    static let neutral50 = UIColor.dynamic(
        light: ColorPalette.neutral50Light,
        dark: ColorPalette.neutral50Dark
    )
    static let neutral100 = UIColor.dynamic(
        light: ColorPalette.neutral100Light,
        dark: ColorPalette.neutral100Dark
    )
    static let neutral500 = UIColor.dynamic(
        light: ColorPalette.neutral500Light,
        dark: ColorPalette.neutral500Dark
    )
    static let neutral900 = UIColor.dynamic(
        light: ColorPalette.neutral900Light,
        dark: ColorPalette.neutral900Dark
    )
    static let success500 = UIColor.dynamic(
        light: ColorPalette.success500Light,
        dark: ColorPalette.success500Dark
    )
    static let warning500 = UIColor.dynamic(
        light: ColorPalette.warning500Light,
        dark: ColorPalette.warning500Dark
    )
    static let error500 = UIColor.dynamic(
        light: ColorPalette.error500Light,
        dark: ColorPalette.error500Dark
    )
    static let info500 = UIColor.dynamic(
        light: ColorPalette.info500Light,
        dark: ColorPalette.info500Dark
    )
}

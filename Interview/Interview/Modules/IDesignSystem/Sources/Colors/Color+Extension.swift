import SwiftUI

public extension Color {
    static let primary50 = Color.dynamic(
        light: ColorPalette.primary50Light,
        dark: ColorPalette.primary50Dark
    )
    static let primary100 = Color.dynamic(
        light: ColorPalette.primary100Light,
        dark: ColorPalette.primary100Dark
    )
    static let primary500 = Color.dynamic(
        light: ColorPalette.primary500Light,
        dark: ColorPalette.primary500Dark
    )
    static let primary700 = Color.dynamic(
        light: ColorPalette.primary700Light,
        dark: ColorPalette.primary700Dark
    )
    static let neutral0 = Color.dynamic(
        light: ColorPalette.neutral0Light,
        dark: ColorPalette.neutral0Dark
    )
    static let neutral50 = Color.dynamic(
        light: ColorPalette.neutral50Light,
        dark: ColorPalette.neutral50Dark
    )
    static let neutral100 = Color.dynamic(
        light: ColorPalette.neutral100Light,
        dark: ColorPalette.neutral100Dark
    )
    static let neutral500 = Color.dynamic(
        light: ColorPalette.neutral500Light,
        dark: ColorPalette.neutral500Dark
    )
    static let neutral900 = Color.dynamic(
        light: ColorPalette.neutral900Light,
        dark: ColorPalette.neutral900Dark
    )
    static let success500 = Color.dynamic(
        light: ColorPalette.success500Light,
        dark: ColorPalette.success500Dark
    )
    static let warning500 = Color.dynamic(
        light: ColorPalette.warning500Light,
        dark: ColorPalette.warning500Dark
    )
    static let error500 = Color.dynamic(
        light: ColorPalette.error500Light,
        dark: ColorPalette.error500Dark
    )
    static let info500 = Color.dynamic(
        light: ColorPalette.info500Light,
        dark: ColorPalette.info500Dark
    )
}

extension Color {
    static func dynamic(light: UIColor, dark: UIColor) -> Color {
        Color(
            uiColor: .dynamic(
                light: light,
                dark: dark
            )
        )
    }

    init(hex: UInt, alpha: Double = 1) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xff) / 255,
            green: Double((hex >> 08) & 0xff) / 255,
            blue: Double((hex >> 00) & 0xff) / 255,
            opacity: alpha
        )
    }

    init?(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")
        var rgb: UInt64 = 0
        let length = hexSanitized.count
        guard Scanner(string: hexSanitized).scanHexInt64(&rgb) else { return nil }
        if length == 6 {
            let r = Double((rgb & 0xFF0000) >> 16) / 255.0
            let g = Double((rgb & 0x00FF00) >> 8) / 255.0
            let b = Double(rgb & 0x0000FF) / 255.0
            self.init(red: r, green: g, blue: b)
        } else {
            return nil
        }
    }
}

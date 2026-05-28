import SwiftUI
import IDesignSystem

enum ColorSchemePreference: String, CaseIterable {
    case system
    case light
    case dark

    var colorScheme: ColorScheme? {
        switch self {
        case .system: nil
        case .light:  .light
        case .dark:   .dark
        }
    }

    var label: String {
        switch self {
        case .system: "System"
        case .light:  "Light"
        case .dark:   "Dark"
        }
    }

    var icon: IconToken {
        switch self {
        case .system: .settings
        case .light:  .sun
        case .dark:   .moon
        }
    }
}

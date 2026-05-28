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
        case .system: Strings.Settings.Appearance.system
        case .light:  Strings.Settings.Appearance.light
        case .dark:   Strings.Settings.Appearance.dark
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

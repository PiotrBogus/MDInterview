import SwiftUI

/// Namespace for all  typography design tokens, grouped by UI section.
///
/// Use with the `.font()` modifier:
///
///     Text("Title").font(TypographyToken.pages.titleBold)
///     Text("Chip").font(TypographyToken.filter.chipsTextRegular)
///
public enum TypographyToken {
    public enum autocomplete {
        public static let eyebrow = TypographyStyle.uniform(
            size: 12,
            weight: .semibold,
            tracking: 0.6,
            lineSpacing: 16
        )

        public static let hero = TypographyStyle.uniform(
            size: 30,
            weight: .bold,
            tracking: -0.8,
            lineSpacing: 36
        )

        public static let sectionTitle = TypographyStyle.uniform(
            size: 22,
            weight: .bold,
            tracking: -0.6,
            lineSpacing: 28
        )

        public static let title = TypographyStyle.uniform(
            size: 18,
            weight: .semibold,
            tracking: -0.5,
            lineSpacing: 24
        )

        public static let body = TypographyStyle.uniform(
            size: 16,
            weight: .regular,
            tracking: -0.2,
            lineSpacing: 22
        )

        public static let bodyStrong = TypographyStyle.uniform(
            size: 16,
            weight: .semibold,
            tracking: -0.3,
            lineSpacing: 22
        )

        public static let searchInput = TypographyStyle.uniform(
            size: 16,
            weight: .medium,
            tracking: -0.2,
            lineSpacing: 20
        )

        public static let resultTitle = TypographyStyle.uniform(
            size: 17,
            weight: .semibold,
            tracking: -0.4,
            lineSpacing: 22
        )

        public static let resultSubtitle = TypographyStyle.uniform(
            size: 14,
            weight: .regular,
            tracking: -0.1,
            lineSpacing: 20
        )

        public static let caption = TypographyStyle.uniform(
            size: 13,
            weight: .medium,
            tracking: 0,
            lineSpacing: 18
        )

        public static let badge = TypographyStyle.uniform(
            size: 12,
            weight: .semibold,
            tracking: 0.3,
            lineSpacing: 16
        )
    }
}

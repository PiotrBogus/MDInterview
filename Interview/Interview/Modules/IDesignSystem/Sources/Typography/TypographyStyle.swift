import SwiftUI

/// A design token representing a complete text style definition.
///
/// Holds a font size for every `ContentSizeCategory`, plus weight, tracking,
/// and optional line height. In Phase 1 all size categories map to the same
/// value from the design spec. Phase 2 allows designers to fill in per-category
/// values without any API change.
public struct TypographyStyle: Sendable, Equatable {

    public let weight: Font.Weight
    /// Letter-spacing in points. Applied via SwiftUI `.tracking()`.
    public let tracking: CGFloat
    /// Designer-specified absolute line height in points. `nil` means system default.
    public let lineSpacing: CGFloat?
    /// Font size keyed by `ContentSizeCategory`. Must contain `.large` as fallback.
    public let sizes: [ContentSizeCategory: CGFloat]

    public init(
        weight: Font.Weight,
        tracking: CGFloat = TypographyStyle.defaultTracking,
        lineSpacing: CGFloat? = nil,
        sizes: [ContentSizeCategory: CGFloat]
    ) {
        self.weight = weight
        self.tracking = tracking
        self.lineSpacing = lineSpacing
        self.sizes = sizes
    }

    /// Default letter-spacing applied to all typography tokens: −0.4 pt.
    public static let defaultTracking: CGFloat = -0.4

    /// Creates a style where every `ContentSizeCategory` maps to the same `size`.
    /// Use this for Phase 1 tokens where Dynamic Type values are not yet specified.
    public static func uniform(
        size: CGFloat,
        weight: Font.Weight = .regular,
        tracking: CGFloat = defaultTracking,
        lineSpacing: CGFloat? = nil
    ) -> TypographyStyle {
        let sizes = Dictionary(
            uniqueKeysWithValues: ContentSizeCategory.typographyAllCases.map { ($0, size) }
        )
        return TypographyStyle(
            weight: weight,
            tracking: tracking,
            lineSpacing: lineSpacing,
            sizes: sizes
        )
    }

    /// Resolves the font size for the given content size category.
    /// Falls back to `.large` (system default category) if the key is missing.
    public func size(for category: ContentSizeCategory) -> CGFloat {
        sizes[category] ?? sizes[.large] ?? 17
    }

    /// Builds a SwiftUI `Font` for the given content size category.
    public func font(for category: ContentSizeCategory) -> Font {
        .system(size: size(for: category), weight: weight)
    }
}

// MARK: - ContentSizeCategory + helpers

extension ContentSizeCategory {
    /// All known `ContentSizeCategory` values, ordered from smallest to largest.
    /// Used internally by `TypographyStyle.uniform()` to populate the sizes dictionary.
    static let typographyAllCases: [ContentSizeCategory] = [
        .extraSmall,
        .small,
        .medium,
        .large,
        .extraLarge,
        .extraExtraLarge,
        .extraExtraExtraLarge,
        .accessibilityMedium,
        .accessibilityLarge,
        .accessibilityExtraLarge,
        .accessibilityExtraExtraLarge,
        .accessibilityExtraExtraExtraLarge
    ]
}

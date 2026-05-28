import SwiftUI

private struct FontModifier: ViewModifier {
    let style: TypographyStyle

    @Environment(\.sizeCategory) private var sizeCategory

    func body(content: Content) -> some View {
        let fontSize = style.size(for: sizeCategory)
        let tracked = content
            .font(style.font(for: sizeCategory))
            .tracking(style.tracking)

        if let designLineHeight = style.lineSpacing {
            // SwiftUI .lineSpacing() adds *extra* space between lines, not absolute
            // line height. We approximate the design spec's absolute line height by
            // subtracting the resolved font size from the designer's line height value.
            // For tokens where lineHeight <= fontSize the extra spacing is clamped to 0.
            let extra = max(0, designLineHeight - fontSize)
            return AnyView(tracked.lineSpacing(extra))
        } else {
            return AnyView(tracked)
        }
    }
}

public extension View {
    /// Apply a  typography token to this view.
    ///
    /// The modifier resolves the correct font size for the user's current
    /// `ContentSizeCategory` automatically.
    ///
    ///     Text("Hello").font(TypographyToken.pages.titleBold)
    ///
    func font(_ style: TypographyStyle) -> some View {
        modifier(FontModifier(style: style))
    }
}

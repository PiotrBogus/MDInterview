import SwiftUI

public struct HeroView: View {
    private let badgeIcon: IconToken
    private let badge: String
    private let title: String?
    private let subtitle: String

    public init(
        badgeIcon: IconToken,
        badge: String,
        title: String? = nil,
        subtitle: String
    ) {
        self.badgeIcon = badgeIcon
        self.badge = badge
        self.title = title
        self.subtitle = subtitle
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: SpacingToken.s10) {
            HStack(spacing: SpacingToken.s8) {
                Image(icon: badgeIcon)
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(Color.primary500)

                Text(verbatim: badge)
                    .font(TypographyToken.autocomplete.badge)
                    .foregroundStyle(Color.primary700)
            }
            .padding(.horizontal, SpacingToken.s12)
            .padding(.vertical, SpacingToken.s8)
            .background(
                Capsule(style: .continuous)
                    .fill(Color.primary50)
            )

            if let title {
                Text(verbatim: title)
                    .font(TypographyToken.autocomplete.sectionTitle)
                    .foregroundStyle(Color.neutral900)
            }

            Text(verbatim: subtitle)
                .font(TypographyToken.autocomplete.resultSubtitle)
                .foregroundStyle(Color.neutral500)
        }
    }
}

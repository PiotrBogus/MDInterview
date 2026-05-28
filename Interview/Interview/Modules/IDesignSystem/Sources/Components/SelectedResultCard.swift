import SwiftUI

public struct SelectedResultCard: View {
    private let icon: IconToken
    private let label: String
    private let title: String
    private let subtitle: String
    private let dismissAccessibilityLabel: String
    private let onDismiss: () -> Void

    public init(
        icon: IconToken,
        label: String,
        title: String,
        subtitle: String,
        dismissAccessibilityLabel: String,
        onDismiss: @escaping () -> Void
    ) {
        self.icon = icon
        self.label = label
        self.title = title
        self.subtitle = subtitle
        self.dismissAccessibilityLabel = dismissAccessibilityLabel
        self.onDismiss = onDismiss
    }

    public var body: some View {
        HStack(alignment: .top, spacing: SpacingToken.s14) {
            ZStack {
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(Color.success500.opacity(0.14))
                    .frame(width: 52, height: 52)

                Image(icon: icon)
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundStyle(Color.success500)
            }

            VStack(alignment: .leading, spacing: SpacingToken.s8) {
                Text(verbatim: label)
                    .font(TypographyToken.autocomplete.badge)
                    .foregroundStyle(Color.success500)

                Text(verbatim: title)
                    .font(TypographyToken.autocomplete.title)
                    .foregroundStyle(Color.neutral900)

                Text(verbatim: subtitle)
                    .font(TypographyToken.autocomplete.resultSubtitle)
                    .foregroundStyle(Color.neutral500)
                    .lineLimit(2)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(SpacingToken.s18)
        .background(
            RoundedRectangle(cornerRadius: 26, style: .continuous)
                .fill(Color.neutral0)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 26, style: .continuous)
                .stroke(Color.neutral100, lineWidth: 1)
        )
        .overlay(alignment: .topTrailing) {
            Button(action: onDismiss) {
                Image(icon: .clear)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(Color.neutral500)
                    .frame(width: 34, height: 34)
                    .background(Circle().fill(Color.neutral0))
                    .overlay(Circle().stroke(Color.neutral100, lineWidth: 1))
            }
            .buttonStyle(.plain)
            .accessibilityLabel(dismissAccessibilityLabel)
            .offset(x: 10, y: -10)
            .shadow(color: Color.neutral900.opacity(0.08), radius: 10, x: 0, y: 6)
        }
        .shadow(color: Color.neutral900.opacity(0.05), radius: 18, x: 0, y: 10)
    }
}

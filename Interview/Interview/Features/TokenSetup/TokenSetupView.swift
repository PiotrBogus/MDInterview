import SwiftUI
import IDesignSystem

struct TokenSetupView: View {
    @StateObject private var viewModel: TokenSetupViewModel

    init(initialToken: String? = nil, onComplete: @escaping (String?) -> Void) {
        _viewModel = StateObject(wrappedValue: TokenSetupViewModel(initialToken: initialToken, onComplete: onComplete))
    }

    var body: some View {
        ZStack {
            background
            ScrollView {
                VStack {
                    Spacer(minLength: SpacingToken.s40)
                    card
                    Spacer(minLength: SpacingToken.s40)
                }
                .padding(.horizontal, SpacingToken.s20)
            }
        }
    }

    // MARK: Card

    private var card: some View {
        VStack(alignment: .leading, spacing: SpacingToken.s24) {
            header
            tokenField
            buttons
        }
        .padding(SpacingToken.s24)
        .background(
            RoundedRectangle(cornerRadius: 30, style: .continuous)
                .fill(Color.neutral0)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 30, style: .continuous)
                .stroke(Color.neutral100, lineWidth: 1)
        )
        .shadow(color: Color.neutral900.opacity(0.08), radius: 24, x: 0, y: 12)
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: SpacingToken.s10) {
            HStack(spacing: SpacingToken.s8) {
                Image(icon: .key)
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(Color.primary500)

                Text(verbatim: Strings.TokenSetup.Header.badge)
                    .font(TypographyToken.autocomplete.badge)
                    .foregroundStyle(Color.primary700)
            }
            .padding(.horizontal, SpacingToken.s12)
            .padding(.vertical, SpacingToken.s8)
            .background(
                Capsule(style: .continuous)
                    .fill(Color.primary50)
            )

            Text(verbatim: Strings.TokenSetup.Header.title)
                .font(TypographyToken.autocomplete.sectionTitle)
                .foregroundStyle(Color.neutral900)

            Text(verbatim: Strings.TokenSetup.Header.subtitle)
                .font(TypographyToken.autocomplete.resultSubtitle)
                .foregroundStyle(Color.neutral500)
        }
    }

    // MARK: Token field

    private var tokenField: some View {
        VStack(alignment: .leading, spacing: SpacingToken.s10) {
            HStack(spacing: SpacingToken.s14) {
                ZStack {
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(Color.primary100)
                        .frame(width: 44, height: 44)

                    Image(icon: .key)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(Color.primary500)
                }

                Group {
                    if viewModel.isTokenVisible {
                        TextField(Strings.TokenSetup.Field.placeholder, text: $viewModel.tokenInput)
                    } else {
                        SecureField(Strings.TokenSetup.Field.placeholder, text: $viewModel.tokenInput)
                    }
                }
                .font(TypographyToken.autocomplete.searchInput)
                .foregroundStyle(Color.neutral900)
                .autocorrectionDisabled()
                .textInputAutocapitalization(.never)

                Button {
                    viewModel.isTokenVisible.toggle()
                } label: {
                    Image(icon: viewModel.isTokenVisible ? .eyeSlash : .eye)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(Color.neutral500)
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, SpacingToken.s16)
            .padding(.vertical, SpacingToken.s14)
            .background(
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .fill(Color.neutral0)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .stroke(Color.primary100, lineWidth: 1)
            )

            Text(verbatim: Strings.TokenSetup.Field.hint)
                .font(TypographyToken.autocomplete.caption)
                .foregroundStyle(Color.neutral500)
                .padding(.horizontal, SpacingToken.s4)
        }
    }

    // MARK: Buttons

    private var buttons: some View {
        VStack(spacing: SpacingToken.s12) {
            Button {
                viewModel.save()
            } label: {
                Text(verbatim: Strings.TokenSetup.Actions.save)
                    .font(TypographyToken.autocomplete.bodyStrong)
                    .foregroundStyle(Color.neutral0)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, SpacingToken.s16)
                    .background(
                        Capsule(style: .continuous)
                            .fill(viewModel.canSave ? Color.primary500 : Color.neutral500)
                    )
            }
            .buttonStyle(.plain)
            .disabled(!viewModel.canSave)

            Button {
                viewModel.skip()
            } label: {
                Text(verbatim: Strings.TokenSetup.Actions.skip)
                    .font(TypographyToken.autocomplete.body)
                    .foregroundStyle(Color.neutral500)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, SpacingToken.s14)
                    .background(
                        Capsule(style: .continuous)
                            .fill(Color.neutral100)
                    )
            }
            .buttonStyle(.plain)
        }
    }

    // MARK: Background

    private var background: some View {
        LinearGradient(
            colors: [Color.primary50, Color.neutral50, Color.neutral0],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .overlay(alignment: .topTrailing) {
            Circle()
                .fill(Color.primary100.opacity(0.9))
                .frame(width: 240, height: 240)
                .blur(radius: 40)
                .offset(x: 80, y: -60)
        }
        .overlay(alignment: .bottomLeading) {
            Circle()
                .fill(Color.info500.opacity(0.12))
                .frame(width: 220, height: 220)
                .blur(radius: 40)
                .offset(x: -70, y: 80)
        }
        .ignoresSafeArea()
    }
}

#Preview {
    TokenSetupView { _ in }
}

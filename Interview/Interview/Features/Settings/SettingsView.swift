import Combine
import SwiftUI
import IDesignSystem

struct SettingsView: View {
    @StateObject private var viewModel: SettingsViewModel
    @Environment(\.dismiss) private var dismiss

    init(colorSchemeService: any ColorSchemeServiceProviding) {
        _viewModel = StateObject(
            wrappedValue: SettingsViewModel(colorSchemeService: colorSchemeService)
        )
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.neutral50
                    .ignoresSafeArea()

                VStack(alignment: .leading, spacing: SpacingToken.s12) {
                    appearanceCard
                    Spacer()
                }
                .padding(.horizontal, SpacingToken.s20)
                .padding(.top, SpacingToken.s16)
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Image(icon: .clear)
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundStyle(Color.neutral500)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .preferredColorScheme(viewModel.state.colorSchemePreference.colorScheme)
    }

    private var appearanceCard: some View {
        VStack(alignment: .leading, spacing: SpacingToken.s4) {
            Text("Appearance")
                .font(TypographyToken.autocomplete.badge)
                .foregroundStyle(Color.neutral500)
                .padding(.horizontal, SpacingToken.s4)
                .padding(.bottom, SpacingToken.s8)

            VStack(spacing: 0) {
                ForEach(ColorSchemePreference.allCases, id: \.self) { option in
                    appearanceRow(option)

                    if option != ColorSchemePreference.allCases.last {
                        Divider()
                            .padding(.leading, SpacingToken.s56)
                    }
                }
            }
            .background(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(Color.neutral0)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .stroke(Color.neutral100, lineWidth: 1)
            )
        }
    }

    private func appearanceRow(_ option: ColorSchemePreference) -> some View {
        let isSelected = viewModel.state.colorSchemePreference == option

        return Button {
            viewModel.send(.colorSchemeChanged(option))
        } label: {
            HStack(spacing: SpacingToken.s14) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(isSelected ? Color.primary100 : Color.neutral100)
                        .frame(width: 40, height: 40)

                    Image(icon: option.icon)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(isSelected ? Color.primary500 : Color.neutral500)
                }

                Text(option.label)
                    .font(TypographyToken.autocomplete.body)
                    .foregroundStyle(Color.neutral900)

                Spacer()

                if isSelected {
                    Image(icon: .selected)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(Color.primary500)
                }
            }
            .padding(.horizontal, SpacingToken.s16)
            .padding(.vertical, SpacingToken.s14)
        }
        .buttonStyle(.plain)
    }
}

private extension SpacingToken {
    static let s56: CGFloat = 56
}

#Preview {
    SettingsView(colorSchemeService: PreviewColorSchemeService())
}

private struct PreviewColorSchemeService: ColorSchemeServiceProviding {
    var preferencePublisher: AnyPublisher<ColorSchemePreference, Never> {
        Just(.system).eraseToAnyPublisher()
    }
    func load() -> ColorSchemePreference { .system }
    func save(_ preference: ColorSchemePreference) {}
}

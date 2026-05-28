import SwiftUI
import IDesignSystem
import Combine

struct SearchView: View {
    @StateObject private var viewModel: SearchViewModel
    @Environment(\.verticalSizeClass) private var verticalSizeClass

    init(searchService: any GitHubSearchProviding, colorSchemeService: any ColorSchemeServiceProviding) {
        _viewModel = StateObject(
            wrappedValue: SearchViewModel(searchService: searchService, colorSchemeService: colorSchemeService)
        )
    }

    var body: some View {
        NavigationStack {
            ZStack {
                background

                VStack(alignment: .leading, spacing: SpacingToken.s18) {
                    if verticalSizeClass != .compact {
                        HeroView(
                            badgeIcon: .searchPrompt,
                            badge: Strings.App.Hero.badge,
                            subtitle: Strings.App.Hero.subtitle
                        )
                        .transition(.opacity.combined(with: .move(edge: .top)))
                    }

                    GitHubAutocompleteView(viewModel: viewModel.searchViewModel)
                    .frame(maxHeight: .infinity, alignment: .top)
                    .layoutPriority(1)

                    Spacer(minLength: 0)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                .padding(.horizontal, SpacingToken.s20)
                .padding(.top, SpacingToken.s16)
                .padding(.bottom, SpacingToken.s16)
                .safeAreaInset(edge: .bottom) {
                    if let selectedItem = viewModel.state.selectedItem {
                        SelectedResultCard(
                            icon: .selected,
                            label: Strings.App.Selected.label,
                            title: selectedItem.title,
                            subtitle: selectedItem.subtitle,
                            dismissAccessibilityLabel: Strings.App.Selected.dismiss
                        ) {
                            viewModel.send(.selectedItemDismissed)
                        }
                        .padding(.horizontal, SpacingToken.s20)
                        .padding(.bottom, SpacingToken.s16)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                    }
                }
            }
            .animation(.spring(duration: 0.4, bounce: 0.1), value: viewModel.state.selectedItem)
            .animation(.spring(duration: 0.35, bounce: 0.1), value: verticalSizeClass)
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(.hidden, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text(verbatim: Strings.App.Hero.title)
                        .font(TypographyToken.autocomplete.bodyStrong)
                        .foregroundStyle(Color.neutral900)
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        viewModel.send(.settingsTapped)
                    } label: {
                        Image(icon: .settings)
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundStyle(Color.neutral900)
                            .frame(width: 36, height: 36)
                            .background(
                                Circle()
                                    .fill(Color.neutral0.opacity(0.85))
                            )
                            .overlay(
                                Circle()
                                    .stroke(Color.neutral100, lineWidth: 1)
                            )
                            .shadow(color: Color.neutral900.opacity(0.06), radius: 8, x: 0, y: 4)
                    }
                    .buttonStyle(.plain)
                }
            }
            .sheet(isPresented: Binding(
                get: { viewModel.state.showsSettings },
                set: { if !$0 { viewModel.send(.settingsDismissed) } }
            )) {
                SettingsView(colorSchemeService: viewModel.colorSchemeService)
            }
        }
        .preferredColorScheme(viewModel.state.colorSchemePreference.colorScheme)
    }

    // MARK: Background

    private var background: some View {
        LinearGradient(
            colors: [
                Color.primary50,
                Color.neutral50,
                Color.neutral0
            ],
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

// MARK: - Preview

#Preview {
    Group {
        SearchView(searchService: PreviewGitHubSearchService(), colorSchemeService: PreviewColorSchemeService())
        SearchView(searchService: PreviewGitHubSearchService(), colorSchemeService: PreviewColorSchemeService())
            .preferredColorScheme(.dark)
    }
}

private struct PreviewColorSchemeService: ColorSchemeServiceProviding {
    var preferencePublisher: AnyPublisher<ColorSchemePreference, Never> {
        Just(.system).eraseToAnyPublisher()
    }
    func load() -> ColorSchemePreference { .system }
    func save(_ preference: ColorSchemePreference) {}
}

private struct PreviewGitHubSearchService: GitHubSearchProviding {
    func search(matching query: String) async throws -> GitHubSearchPage {
        GitHubSearchPage(
            items: [
                .repository(GitHubRepository(
                    id: 1, name: "awesome-ios",
                    fullName: "example/awesome-ios",
                    htmlURL: URL(string: "https://github.com/example/awesome-ios")!
                )),
                .user(GitHubUser(
                    id: 2, login: "apple",
                    htmlURL: URL(string: "https://github.com/apple")!
                ))
            ],
            nextCursor: nil
        )
    }

    func loadNextPage(matching query: String, cursor: GitHubSearchCursor) async throws -> GitHubSearchPage {
        .empty
    }
}

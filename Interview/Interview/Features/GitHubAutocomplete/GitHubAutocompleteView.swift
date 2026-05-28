import SwiftUI
import IDesignSystem

struct GitHubAutocompleteView: View {
    @ObservedObject private var viewModel: GitHubAutocompleteViewModel
    @Environment(\.verticalSizeClass) private var verticalSizeClass
    @FocusState private var isSearchFocused: Bool
    @State private var isCollapsed = false

    private var isHeaderVisible: Bool {
        !isCollapsed && verticalSizeClass != .compact
    }

    init(viewModel: GitHubAutocompleteViewModel) {
        _viewModel = ObservedObject(wrappedValue: viewModel)
    }

    var body: some View {
        Group {
            if verticalSizeClass == .compact {
                landscapeLayout
            } else {
                portraitLayout
            }
        }
        .animation(.spring(duration: 0.35, bounce: 0.1), value: isHeaderVisible)
        .onChange(of: viewModel.state.viewStatus) { _, status in
            if case .results = status { } else {
                isCollapsed = false
            }
        }
        .padding(SpacingToken.s20)
        .background(
            RoundedRectangle(cornerRadius: 30, style: .continuous)
                .fill(Color.neutral0)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 30, style: .continuous)
                .stroke(Color.neutral100, lineWidth: 1)
        )
        .shadow(color: Color.neutral900.opacity(0.08), radius: 24, x: 0, y: 12)
        .frame(maxHeight: .infinity, alignment: .top)
    }

    private var portraitLayout: some View {
        VStack(alignment: .leading, spacing: SpacingToken.s18) {
            if isHeaderVisible {
                header
                    .transition(.opacity.combined(with: .move(edge: .top)))
            }
            searchField
            content
        }
    }

    private var landscapeLayout: some View {
        HStack(alignment: .top, spacing: SpacingToken.s16) {
            searchField
                .frame(width: 260)

            Rectangle()
                .fill(Color.neutral100)
                .frame(width: 1)

            content
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: SpacingToken.s10) {
            HStack(spacing: SpacingToken.s8) {
                Image(icon: .pulse)
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(Color.primary500)

                Text(verbatim: Strings.GitHubSearch.Header.badge)
                    .font(TypographyToken.autocomplete.badge)
                    .foregroundStyle(Color.primary700)
            }
            .padding(.horizontal, SpacingToken.s12)
            .padding(.vertical, SpacingToken.s8)
            .background(
                Capsule(style: .continuous)
                    .fill(Color.primary50)
            )

            if let title = viewModel.title {
                Text(verbatim: title)
                    .font(TypographyToken.autocomplete.sectionTitle)
                    .foregroundStyle(Color.neutral900)
            }

            Text(verbatim: Strings.GitHubSearch.Header.subtitle)
                .font(TypographyToken.autocomplete.resultSubtitle)
                .foregroundStyle(Color.neutral500)
        }
    }

    private var searchField: some View {
        VStack(alignment: .leading, spacing: SpacingToken.s10) {
            HStack(spacing: SpacingToken.s14) {
                ZStack {
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(Color.primary100)
                        .frame(width: 44, height: 44)

                    Image(icon: .search)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(Color.primary500)
                }

                TextField(
                    viewModel.placeholder,
                    text: Binding(
                        get: { viewModel.state.query },
                        set: { viewModel.send(.queryChanged($0)) }
                    )
                )
                .font(TypographyToken.autocomplete.searchInput)
                .foregroundStyle(Color.neutral900)
                .focused($isSearchFocused)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .tint(Color.primary500)

                trailingSearchAccessory
            }
            .padding(.horizontal, SpacingToken.s16)
            .padding(.vertical, SpacingToken.s14)
            .background(
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .fill(Color.neutral0)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .stroke(
                        isSearchFocused ? Color.primary500 : Color.primary100,
                        lineWidth: isSearchFocused ? 2 : 1
                    )
            )
            .shadow(
                color: isSearchFocused
                    ? Color.primary500.opacity(0.16)
                    : Color.neutral900.opacity(0.05),
                radius: isSearchFocused ? 18 : 10,
                x: 0,
                y: 6
            )

            HStack {
                Text(verbatim: Strings.GitHubSearch.Search.captionMinimum(viewModel.minimumQueryLength))
                Spacer()
                Text(verbatim: Strings.GitHubSearch.Search.captionTypes)
            }
            .font(TypographyToken.autocomplete.caption)
            .foregroundStyle(Color.neutral500)
            .padding(.horizontal, SpacingToken.s4)
        }
    }

    @ViewBuilder
    private var trailingSearchAccessory: some View {
        if viewModel.state.isDebouncing || viewModel.state.viewStatus == .loading {
            ProgressView()
                .tint(Color.primary500)
        } else if !viewModel.state.query.isEmpty {
            Button {
                viewModel.send(.queryChanged(""))
            } label: {
                Image(icon: .clear)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(Color.neutral500)
            }
            .buttonStyle(.plain)
        }
    }

    @ViewBuilder
    private var content: some View {
        switch viewModel.state.viewStatus {
        case .idle:
            statusView(
                icon: .searchPrompt,
                tint: Color.primary500,
                title: Strings.GitHubSearch.Idle.title,
                message: Strings.GitHubSearch.Idle.subtitle(viewModel.minimumQueryLength)
            )
        case .loading:
            VStack(spacing: SpacingToken.s14) {
                ProgressView()
                    .tint(Color.primary500)
                    .scaleEffect(1.1)
                Text(verbatim: Strings.GitHubSearch.Loading.title)
                    .font(TypographyToken.autocomplete.title)
                    .foregroundStyle(Color.neutral900)
                Text(verbatim: Strings.GitHubSearch.Loading.subtitle)
                    .font(TypographyToken.autocomplete.body)
                    .foregroundStyle(Color.neutral500)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, SpacingToken.s40)
            .padding(.horizontal, SpacingToken.s20)
            .background(
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .fill(Color.neutral50)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .stroke(Color.neutral100, lineWidth: 1)
            )
        case .empty:
            statusView(
                icon: .empty,
                tint: Color.warning500,
                title: Strings.GitHubSearch.Empty.title,
                message: Strings.GitHubSearch.Empty.subtitle
            )
        case .error(let message):
            statusView(
                icon: .error,
                tint: Color.error500,
                title: Strings.GitHubSearch.Error.title,
                message: message
            )
        case .results:
            VStack(alignment: .leading, spacing: SpacingToken.s12) {
                HStack(spacing: SpacingToken.s8) {
                    Text(verbatim: Strings.GitHubSearch.Result.loadedCount(viewModel.state.items.count))
                        .font(TypographyToken.autocomplete.badge)
                        .foregroundStyle(Color.primary700)
                        .padding(.horizontal, SpacingToken.s12)
                        .padding(.vertical, SpacingToken.s8)
                        .background(
                            Capsule(style: .continuous)
                                .fill(Color.primary50)
                        )

                    if viewModel.state.hasNextPage {
                        Text(verbatim: Strings.GitHubSearch.Pagination.keepScrolling)
                            .font(TypographyToken.autocomplete.caption)
                            .foregroundStyle(Color.neutral500)
                    }
                }

                ScrollView {
                    LazyVStack(spacing: SpacingToken.s12) {
                        ForEach(viewModel.state.items) { item in
                            resultRow(item)
                        }

                        if viewModel.state.hasNextPage || viewModel.state.isLoadingNextPage || viewModel.state.paginationErrorMessage != nil {
                            paginationFooter
                                .id(viewModel.state.paginationTriggerID)
                                .onAppear {
                                    guard viewModel.state.hasNextPage else { return }
                                    guard !viewModel.state.isLoadingNextPage else { return }
                                    guard viewModel.state.paginationErrorMessage == nil else { return }
                                    viewModel.send(.retryLoadNextPage)
                                }
                        }
                    }
                    .padding(.vertical, SpacingToken.s4)
                }
                .scrollIndicators(.hidden)
                .frame(maxHeight: .infinity)
                .onScrollGeometryChange(for: CGFloat.self) { geo in
                    geo.contentOffset.y
                } action: { _, newOffset in
                    isCollapsed = newOffset > 20
                }
            }
        }
    }

    private func resultRow(_ item: GitHubAutocompleteItem) -> some View {
        let accentColor = accentColor(for: item)

        return Button {
            viewModel.onSelection(item)
        } label: {
            HStack(alignment: .center, spacing: SpacingToken.s14) {
                ZStack {
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .fill(accentColor.opacity(0.14))
                        .frame(width: 52, height: 52)

                    Image(icon: icon(for: item))
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundStyle(accentColor)
                }

                VStack(alignment: .leading, spacing: SpacingToken.s6) {
                    Text(verbatim: item.title)
                        .font(TypographyToken.autocomplete.resultTitle)
                        .foregroundStyle(Color.neutral900)
                        .multilineTextAlignment(.leading)

                    Text(verbatim: item.subtitle)
                        .font(TypographyToken.autocomplete.resultSubtitle)
                        .foregroundStyle(Color.neutral500)
                        .lineLimit(2)

                    Text(verbatim: kindLabel(for: item))
                        .font(TypographyToken.autocomplete.badge)
                        .foregroundStyle(accentColor)
                        .padding(.horizontal, SpacingToken.s10)
                        .padding(.vertical, SpacingToken.s6)
                        .background(
                            Capsule(style: .continuous)
                                .fill(accentColor.opacity(0.12))
                        )
                }

                Spacer(minLength: SpacingToken.s12)

                Image(icon: .external)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(Color.neutral500)
            }
            .padding(SpacingToken.s16)
            .background(
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .fill(Color.neutral50)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .stroke(Color.neutral100, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }

    @ViewBuilder
    private var paginationFooter: some View {
        if let paginationErrorMessage = viewModel.state.paginationErrorMessage {
            VStack(spacing: SpacingToken.s10) {
                Text(verbatim: paginationErrorMessage)
                    .font(TypographyToken.autocomplete.resultSubtitle)
                    .foregroundStyle(Color.neutral500)
                    .multilineTextAlignment(.center)

                Button(Strings.GitHubSearch.Pagination.retry) {
                    viewModel.send(.retryLoadNextPage)
                }
                .font(TypographyToken.autocomplete.bodyStrong)
                .foregroundStyle(Color.neutral0)
                .padding(.horizontal, SpacingToken.s18)
                .padding(.vertical, SpacingToken.s12)
                .background(
                    Capsule(style: .continuous)
                        .fill(Color.primary500)
                )
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, SpacingToken.s12)
        } else if viewModel.state.isLoadingNextPage {
            HStack(spacing: SpacingToken.s10) {
                ProgressView()
                    .tint(Color.primary500)
                Text(verbatim: Strings.GitHubSearch.Pagination.loading)
                    .font(TypographyToken.autocomplete.bodyStrong)
                    .foregroundStyle(Color.neutral900)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, SpacingToken.s14)
            .background(
                Capsule(style: .continuous)
                    .fill(Color.primary50)
            )
        } else if viewModel.state.hasNextPage {
            HStack(spacing: SpacingToken.s8) {
                Image(icon: .chevron)
                    .font(.system(size: 12, weight: .semibold))
                Text(verbatim: Strings.GitHubSearch.Pagination.keepScrolling)
                    .font(TypographyToken.autocomplete.bodyStrong)
            }
            .foregroundStyle(Color.primary700)
            .frame(maxWidth: .infinity)
            .padding(.vertical, SpacingToken.s14)
            .background(
                Capsule(style: .continuous)
                    .fill(Color.primary50)
            )
        }
    }

    private func statusView(icon: IconToken, tint: Color, title: String, message: String) -> some View {
        VStack(spacing: SpacingToken.s14) {
            ZStack {
                Circle()
                    .fill(tint.opacity(0.14))
                    .frame(width: 68, height: 68)

                Image(icon: icon)
                    .font(.system(size: 28, weight: .semibold))
                    .foregroundStyle(tint)
            }

            Text(verbatim: title)
                .font(TypographyToken.autocomplete.title)
                .foregroundStyle(Color.neutral900)
            Text(verbatim: message)
                .font(TypographyToken.autocomplete.body)
                .foregroundStyle(Color.neutral500)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, SpacingToken.s40)
        .padding(.horizontal, SpacingToken.s20)
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(Color.neutral50)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(Color.neutral100, lineWidth: 1)
        )
    }

    private func kindLabel(for item: GitHubAutocompleteItem) -> String {
        switch item {
        case .repository: Strings.GitHubSearch.Result.kindRepository
        case .user:       Strings.GitHubSearch.Result.kindUser
        }
    }

    private func icon(for item: GitHubAutocompleteItem) -> IconToken {
        switch item {
        case .repository: .repository
        case .user:       .user
        }
    }

    private func accentColor(for item: GitHubAutocompleteItem) -> Color {
        switch item {
        case .repository: .primary500
        case .user:       .info500
        }
    }
}

#Preview {
    Group {
        NavigationStack {
            GitHubAutocompleteView(
                viewModel: GitHubAutocompleteViewModel(
                    service: PreviewGitHubSearchService(),
                    title: Strings.App.Search.title
                )
            )
            .padding()
            .background(Color.neutral50)
        }

        NavigationStack {
            GitHubAutocompleteView(
                viewModel: GitHubAutocompleteViewModel(
                    service: PreviewGitHubSearchService(),
                    title: Strings.App.Search.title
                )
            )
            .padding()
            .background(Color.neutral50)
        }
        .preferredColorScheme(.dark)
    }
}

private struct PreviewGitHubSearchService: GitHubSearchProviding {
    func search(matching query: String) async throws -> GitHubSearchPage {
        GitHubSearchPage(
            items: [
                .repository(
                    GitHubRepository(
                        id: 1,
                        name: "awesome-ios",
                        fullName: "example/awesome-ios",
                        htmlURL: URL(string: "https://github.com/example/awesome-ios")!
                    )
                ),
                .user(
                    GitHubUser(
                        id: 2,
                        login: "apple",
                        htmlURL: URL(string: "https://github.com/apple")!
                    )
                )
            ],
            nextCursor: GitHubSearchCursor(
                nextUsersPage: 2,
                nextRepositoriesPage: nil,
                bufferedItems: []
            )
        )
    }

    func loadNextPage(
        matching query: String,
        cursor: GitHubSearchCursor
    ) async throws -> GitHubSearchPage {
        GitHubSearchPage(
            items: [
                .user(
                    GitHubUser(
                        id: 3,
                        login: "apple-docs",
                        htmlURL: URL(string: "https://github.com/apple-docs")!
                    )
                )
            ],
            nextCursor: nil
        )
    }
}

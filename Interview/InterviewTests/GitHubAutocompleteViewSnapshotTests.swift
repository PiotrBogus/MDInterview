import Combine
import SnapshotTesting
import SwiftUI
import Testing
@testable import Interview

@Suite("GitHubAutocompleteView — Snapshots")
@MainActor
struct GitHubAutocompleteViewSnapshotTests {

    // MARK: - Idle

    @Test
    func idle_light() {
        assertSnapshot(of: makeView(), as: .light)
    }

    @Test
    func idle_dark() {
        assertSnapshot(of: makeView(), as: .dark)
    }

    // MARK: - Loading

    @Test
    func loading_light() {
        assertSnapshot(of: makeView { $0.send(.searchStarted) }, as: .light)
    }

    @Test
    func loading_dark() {
        assertSnapshot(of: makeView { $0.send(.searchStarted) }, as: .dark)
    }

    // MARK: - Results

    @Test
    func results_light() {
        assertSnapshot(of: makeView(state: .results), as: .light)
    }

    @Test
    func results_dark() {
        assertSnapshot(of: makeView(state: .results), as: .dark)
    }

    // MARK: - No results

    @Test
    func noResults_light() {
        assertSnapshot(of: makeView(state: .empty), as: .light)
    }

    @Test
    func noResults_dark() {
        assertSnapshot(of: makeView(state: .empty), as: .dark)
    }

    // MARK: - Error

    @Test
    func error_light() {
        assertSnapshot(of: makeView(state: .error), as: .light)
    }

    @Test
    func error_dark() {
        assertSnapshot(of: makeView(state: .error), as: .dark)
    }
}

// MARK: - Helpers

private enum AutocompleteState {
    case idle, results, empty, error
}

@MainActor
private func makeView(
    state: AutocompleteState = .idle,
    configure: (GitHubAutocompleteViewModel) -> Void = { _ in }
) -> some View {
    let viewModel = GitHubAutocompleteViewModel(
        service: SuspendingSearchService(),
        title: "Find GitHub resources",
        debounceDuration: .zero,
        sleep: { _ in }
    )

    switch state {
    case .idle:
        break
    case .results:
        viewModel.send(.queryChanged("swift"))
        viewModel.send(.searchLoaded(
            query: "swift",
            page: GitHubSearchPage(
                items: [
                    .repository(GitHubRepository(
                        id: 1, name: "swift",
                        fullName: "apple/swift",
                        htmlURL: URL(string: "https://github.com/apple/swift")!
                    )),
                    .user(GitHubUser(
                        id: 2, login: "swiftlang",
                        htmlURL: URL(string: "https://github.com/swiftlang")!
                    )),
                    .repository(GitHubRepository(
                        id: 3, name: "swift-evolution",
                        fullName: "apple/swift-evolution",
                        htmlURL: URL(string: "https://github.com/apple/swift-evolution")!
                    ))
                ],
                nextCursor: nil
            )
        ))
    case .empty:
        viewModel.send(.queryChanged("zzznoresults"))
        viewModel.send(.searchLoaded(
            query: "zzznoresults",
            page: GitHubSearchPage(items: [], nextCursor: nil)
        ))
    case .error:
        viewModel.send(.queryChanged("swift"))
        viewModel.send(.searchFailed(
            query: "swift",
            message: "API rate limit exceeded. Please add a GitHub token in Settings."
        ))
    }

    configure(viewModel)

    return GitHubAutocompleteView(viewModel: viewModel)
}

private extension Snapshotting where Value: View, Format == UIImage {
    static var light: Self {
        .image(layout: .fixed(width: 390, height: 600))
    }

    static var dark: Self {
        .image(layout: .fixed(width: 390, height: 600), traits: .init(userInterfaceStyle: .dark))
    }
}

private struct SuspendingSearchService: GitHubSearchProviding {
    func search(matching query: String) async throws -> GitHubSearchPage {
        try await Task.sleep(for: .seconds(3_600))
        return .empty
    }

    func loadNextPage(matching query: String, cursor: GitHubSearchCursor) async throws -> GitHubSearchPage {
        .empty
    }
}

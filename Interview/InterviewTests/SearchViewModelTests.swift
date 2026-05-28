import Combine
import Foundation
import Testing
@testable import Interview

@Suite("SearchViewModel")
@MainActor
struct SearchViewModelTests {

    // MARK: - Initial state

    @Test
    func initialStateLoadsColorSchemeFromService() {
        let service = MockColorSchemeService(initial: .dark)
        let viewModel = makeViewModel(colorSchemeService: service)

        #expect(viewModel.state.colorSchemePreference == .dark)
        #expect(viewModel.state.selectedItem == nil)
        #expect(viewModel.state.showsSettings == false)
    }

    // MARK: - Item selection

    @Test
    func itemSelectedSetsSelectedItem() {
        let viewModel = makeViewModel()
        let item = GitHubAutocompleteItem.user(
            GitHubUser(id: 1, login: "octocat", htmlURL: URL(string: "https://github.com/octocat")!)
        )

        viewModel.send(.itemSelected(item))

        #expect(viewModel.state.selectedItem == item)
    }

    @Test
    func selectedItemDismissedClearsSelection() {
        let viewModel = makeViewModel()
        let item = GitHubAutocompleteItem.repository(
            GitHubRepository(id: 1, name: "swift", fullName: "apple/swift", htmlURL: URL(string: "https://github.com/apple/swift")!)
        )

        viewModel.send(.itemSelected(item))
        viewModel.send(.selectedItemDismissed)

        #expect(viewModel.state.selectedItem == nil)
    }

    @Test
    func itemSelectedReplacesExistingSelection() {
        let viewModel = makeViewModel()
        let first = GitHubAutocompleteItem.user(
            GitHubUser(id: 1, login: "first", htmlURL: URL(string: "https://github.com/first")!)
        )
        let second = GitHubAutocompleteItem.user(
            GitHubUser(id: 2, login: "second", htmlURL: URL(string: "https://github.com/second")!)
        )

        viewModel.send(.itemSelected(first))
        viewModel.send(.itemSelected(second))

        #expect(viewModel.state.selectedItem == second)
    }

    // MARK: - Settings sheet

    @Test
    func settingsTappedOpensSheet() {
        let viewModel = makeViewModel()

        viewModel.send(.settingsTapped)

        #expect(viewModel.state.showsSettings == true)
    }

    @Test
    func settingsDismissedClosesSheet() {
        let viewModel = makeViewModel()

        viewModel.send(.settingsTapped)
        viewModel.send(.settingsDismissed)

        #expect(viewModel.state.showsSettings == false)
    }

    // MARK: - Color scheme

    @Test
    func colorSchemeChangedUpdatesPreference() {
        let viewModel = makeViewModel()

        viewModel.send(.colorSchemeChanged(.dark))

        #expect(viewModel.state.colorSchemePreference == .dark)
    }

    @Test
    func colorSchemePublisherUpdatesStateWhenServiceEmitsNewValue() async throws {
        let service = MockColorSchemeService(initial: .system)
        let viewModel = makeViewModel(colorSchemeService: service)

        service.emit(.light)
        try await Task.sleep(for: .milliseconds(20))

        #expect(viewModel.state.colorSchemePreference == .light)
    }

    @Test
    func colorSchemePublisherIgnoresInitialEmission() async throws {
        let service = MockColorSchemeService(initial: .dark)
        let viewModel = makeViewModel(colorSchemeService: service)

        try await Task.sleep(for: .milliseconds(20))

        #expect(viewModel.state.colorSchemePreference == .dark)
    }

    // MARK: - Search ViewModel integration

    @Test
    func searchViewModelOnSelectionForwardsItemToState() {
        let viewModel = makeViewModel()
        let item = GitHubAutocompleteItem.repository(
            GitHubRepository(id: 42, name: "vapor", fullName: "vapor/vapor", htmlURL: URL(string: "https://github.com/vapor/vapor")!)
        )

        viewModel.searchViewModel.onSelection(item)

        #expect(viewModel.state.selectedItem == item)
    }
}

// MARK: - Helpers

@MainActor
private func makeViewModel(
    colorSchemeService: MockColorSchemeService = MockColorSchemeService()
) -> SearchViewModel {
    SearchViewModel(
        searchService: MockSearchService(),
        colorSchemeService: colorSchemeService
    )
}

// MARK: - Mocks

private final class MockColorSchemeService: ColorSchemeServiceProviding, @unchecked Sendable {
    private let subject: CurrentValueSubject<ColorSchemePreference, Never>

    var preferencePublisher: AnyPublisher<ColorSchemePreference, Never> {
        subject.eraseToAnyPublisher()
    }

    init(initial: ColorSchemePreference = .system) {
        subject = CurrentValueSubject(initial)
    }

    func load() -> ColorSchemePreference { subject.value }
    func save(_ preference: ColorSchemePreference) { subject.send(preference) }
    func emit(_ preference: ColorSchemePreference) { subject.send(preference) }
}

private struct MockSearchService: GitHubSearchProviding {
    func search(matching query: String) async throws -> GitHubSearchPage { .empty }
    func loadNextPage(matching query: String, cursor: GitHubSearchCursor) async throws -> GitHubSearchPage { .empty }
}

import Combine
import Foundation

@MainActor
final class SearchViewModel: ObservableObject {

    struct State: Equatable {
        var selectedItem: GitHubAutocompleteItem?
        var showsSettings = false
        var colorSchemePreference: ColorSchemePreference = .system
    }

    enum Action {
        case itemSelected(GitHubAutocompleteItem)
        case selectedItemDismissed
        case settingsTapped
        case settingsDismissed
        case colorSchemeChanged(ColorSchemePreference)
    }

    @Published private(set) var state: State
    let colorSchemeService: any ColorSchemeServiceProviding

    private let searchService: any GitHubSearchProviding
    private var cancellables = Set<AnyCancellable>()

    private(set) lazy var searchViewModel: GitHubAutocompleteViewModel = {
        GitHubAutocompleteViewModel(
            service: searchService,
            title: Strings.App.Search.title,
            onSelection: { [weak self] item in
                self?.send(.itemSelected(item))
            }
        )
    }()

    init(
        searchService: any GitHubSearchProviding,
        colorSchemeService: any ColorSchemeServiceProviding
    ) {
        self.searchService = searchService
        self.colorSchemeService = colorSchemeService
        self.state = State(colorSchemePreference: colorSchemeService.load())

        setUpListener()
    }

    func send(_ action: Action) {
        switch action {
        case .itemSelected(let item):
            state.selectedItem = item
        case .selectedItemDismissed:
            state.selectedItem = nil
        case .settingsTapped:
            state.showsSettings = true
        case .settingsDismissed:
            state.showsSettings = false
        case .colorSchemeChanged(let preference):
            state.colorSchemePreference = preference
        }
    }

    private func setUpListener() {
        colorSchemeService.preferencePublisher
            .dropFirst()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] preference in
                self?.send(.colorSchemeChanged(preference))
            }
            .store(in: &cancellables)
    }
}

import Foundation
import Combine
import INetwork

@MainActor
final class GitHubAutocompleteViewModel: ObservableObject {
    enum ViewStatus: Equatable {
        case idle
        case loading
        case results
        case empty
        case error(String)
    }

    struct State: Equatable {
        var query = ""
        var items: [GitHubAutocompleteItem] = []
        var viewStatus: ViewStatus = .idle
        var isDebouncing = false
        var isLoadingNextPage = false
        var paginationErrorMessage: String?
        var nextCursor: GitHubSearchCursor?

        var hasNextPage: Bool {
            nextCursor?.hasMoreResults == true
        }

        var paginationTriggerID: String {
            "\(nextCursor?.nextUsersPage?.description ?? "nil")-\(nextCursor?.nextRepositoriesPage?.description ?? "nil")-\(nextCursor?.bufferedItems.count ?? 0)-\(items.count)"
        }
    }

    enum Action {
        case queryChanged(String)
        case loadNextPageIfNeeded(currentItemID: GitHubAutocompleteItem.ID)
        case retryLoadNextPage
        case searchStarted
        case searchLoaded(query: String, page: GitHubSearchPage)
        case searchFailed(query: String, message: String)
        case nextPageStarted
        case nextPageLoaded(
            query: String,
            page: GitHubSearchPage
        )
        case nextPageFailed(query: String, message: String)
    }

    @Published private(set) var state = State()

    let minimumQueryLength: Int
    let title: String?
    let placeholder: String
    let onSelection: (GitHubAutocompleteItem) -> Void

    private let service: any GitHubSearchProviding
    private let debounceDuration: Duration
    private let sleep: @Sendable (Duration) async throws -> Void
    var searchTask: Task<Void, Never>?
    var paginationTask: Task<Void, Never>?

    init(
        service: any GitHubSearchProviding,
        title: String? = nil,
        placeholder: String? = nil,
        onSelection: @escaping (GitHubAutocompleteItem) -> Void = { _ in },
        minimumQueryLength: Int = 3,
        debounceDuration: Duration = .milliseconds(300),
        sleep: @escaping @Sendable (Duration) async throws -> Void = { duration in
            try await Task<Never, Never>.sleep(for: duration)
        }
    ) {
        self.service = service
        self.title = title
        self.placeholder = placeholder ?? Strings.GitHubSearch.Search.placeholder
        self.onSelection = onSelection
        self.minimumQueryLength = minimumQueryLength
        self.debounceDuration = debounceDuration
        self.sleep = sleep
    }

    deinit {
        searchTask?.cancel()
        paginationTask?.cancel()
    }

    func send(_ action: Action) {
        switch action {
        case .queryChanged(let newValue):
            state.query = newValue
            scheduleSearch()

        case .loadNextPageIfNeeded(let currentItemID):
            guard currentItemID == state.items.last?.id else { return }
            guard state.paginationErrorMessage == nil else { return }
            loadNextPage()

        case .retryLoadNextPage:
            loadNextPage()

        case .searchStarted:
            state.isDebouncing = false
            state.viewStatus = .loading

        case .searchLoaded(let query, let page):
            guard currentQuery == query else { return }
            state.items = page.items
            state.isDebouncing = false
            state.nextCursor = page.nextCursor
            state.paginationErrorMessage = nil
            state.isLoadingNextPage = false
            state.viewStatus = page.items.isEmpty ? .empty : .results

        case .searchFailed(let query, let message):
            guard currentQuery == query else { return }
            state.items = []
            state.isDebouncing = false
            state.nextCursor = nil
            state.isLoadingNextPage = false
            state.paginationErrorMessage = nil
            state.viewStatus = .error(message)

        case .nextPageStarted:
            state.isLoadingNextPage = true
            state.paginationErrorMessage = nil

        case .nextPageLoaded(let query, let page):
            guard currentQuery == query else { return }
            state.items = merge(existing: state.items, with: page.items)
            state.nextCursor = page.nextCursor
            state.isLoadingNextPage = false

        case .nextPageFailed(let query, let message):
            guard currentQuery == query else { return }
            state.isLoadingNextPage = false
            state.paginationErrorMessage = message
        }
    }

    private var currentQuery: String {
        state.query.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private func scheduleSearch() {
        searchTask?.cancel()
        paginationTask?.cancel()
        state.isDebouncing = false
        state.isLoadingNextPage = false
        state.paginationErrorMessage = nil
        state.nextCursor = nil

        let trimmedQuery = currentQuery
        guard trimmedQuery.count >= minimumQueryLength else {
            state.items = []
            state.viewStatus = .idle
            return
        }
        state.isDebouncing = true
        let service = self.service
        let debounceDuration = self.debounceDuration
        let sleep = self.sleep

        searchTask = Task { [weak self] in
            do {
                try await sleep(debounceDuration)
                try Task.checkCancellation()

                await MainActor.run {
                    self?.send(.searchStarted)
                }

                let page = try await service.search(matching: trimmedQuery)
                try Task.checkCancellation()

                await MainActor.run {
                    self?.send(.searchLoaded(query: trimmedQuery, page: page))
                }
            } catch is CancellationError {
                return
            } catch {
                await MainActor.run {
                    self?.send(
                        .searchFailed(
                            query: trimmedQuery,
                            message: Self.userMessage(for: error, whileLoadingNextPage: false)
                        )
                    )
                }
            }
        }
    }

    private func loadNextPage() {
        let trimmedQuery = currentQuery
        guard trimmedQuery.count >= minimumQueryLength else { return }
        guard !state.isLoadingNextPage else { return }

        guard let cursor = state.nextCursor, cursor.hasMoreResults else { return }

        send(.nextPageStarted)
        let service = self.service

        paginationTask?.cancel()
        paginationTask = Task { [weak self] in
            do {
                let page = try await service.loadNextPage(
                    matching: trimmedQuery,
                    cursor: cursor
                )
                try Task.checkCancellation()

                await MainActor.run {
                    self?.send(
                        .nextPageLoaded(
                            query: trimmedQuery,
                            page: page
                        )
                    )
                }
            } catch is CancellationError {
                return
            } catch {
                await MainActor.run {
                    self?.send(
                        .nextPageFailed(
                            query: trimmedQuery,
                            message: Self.userMessage(for: error, whileLoadingNextPage: true)
                        )
                    )
                }
            }
        }
    }

    private func merge(
        existing: [GitHubAutocompleteItem],
        with newItems: [GitHubAutocompleteItem]
    ) -> [GitHubAutocompleteItem] {
        let merged = Dictionary(
            uniqueKeysWithValues: (existing + newItems).map { ($0.id, $0) }
        )

        return merged.values.sorted { left, right in
            left.sortKey < right.sortKey
        }
    }

    private static func userMessage(
        for error: Error,
        whileLoadingNextPage: Bool
    ) -> String {
        switch error {
        case NetworkRequestError.forbidden:
            return Strings.GitHubSearch.Error.messageForbidden
        case NetworkRequestError.unauthorized:
            return Strings.GitHubSearch.Error.messageUnauthorized
        default:
            return whileLoadingNextPage
                ? Strings.GitHubSearch.Error.messageNextPage
                : Strings.GitHubSearch.Error.messageSearch
        }
    }
}

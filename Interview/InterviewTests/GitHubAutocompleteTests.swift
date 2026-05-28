import Foundation
import INetwork
import Testing
@testable import Interview

@Suite("GitHub Autocomplete")
@MainActor
struct GitHubAutocompleteTests {

    @Test
    func searchCombinesSortsAndLimitsResults() async throws {
        let users = (0..<30).map { index in
            GitHubUser(
                id: index,
                login: "user-\(String(format: "%02d", index))",
                htmlURL: URL(string: "https://github.com/user-\(index)")!
            )
        }.reversed()

        let repositories = (0..<30).map { index in
            GitHubRepository(
                id: 100 + index,
                name: "repo-\(String(format: "%02d", index))",
                fullName: "example/repo-\(index)",
                htmlURL: URL(string: "https://github.com/example/repo-\(index)")!
            )
        }.reversed()

        let service = GitHubSearchService(
            networking: MockGitHubSearchNetworking(
                usersByPage: [1: SearchResponse(totalCount: 30, items: Array(users))],
                repositoriesByPage: [1: SearchResponse(totalCount: 30, items: Array(repositories))]
            )
        )

        let results = try await service.search(matching: "swift")

        #expect(results.items.count == 50)
        #expect(results.items.map(\.title) == results.items.map(\.title).sorted())
        #expect(results.items.first?.title == "repo-00")
        #expect(results.items.last?.title == "user-24")
        #expect(results.hasMoreUsers == true)
        #expect(results.hasMoreRepositories == true)
    }

    @Test
    func searchKeepsCombinedPageSizeAtFiftyWithBufferedOverflow() async throws {
        let users = (0..<10).map { index in
            GitHubUser(
                id: index,
                login: "user-\(String(format: "%02d", index))",
                htmlURL: URL(string: "https://github.com/user-\(index)")!
            )
        }

        let repositories = (0..<100).map { index in
            GitHubRepository(
                id: 100 + index,
                name: "repo-\(String(format: "%02d", index))",
                fullName: "example/repo-\(index)",
                htmlURL: URL(string: "https://github.com/example/repo-\(index)")!
            )
        }

        let service = GitHubSearchService(
            networking: MockGitHubSearchNetworking(
                usersByPage: [
                    1: SearchResponse(totalCount: 10, items: Array(users.prefix(10)))
                ],
                repositoriesByPage: [
                    1: SearchResponse(totalCount: 100, items: Array(repositories.prefix(25))),
                    2: SearchResponse(totalCount: 100, items: Array(repositories.dropFirst(25).prefix(25)))
                ]
            )
        )

        let firstPage = try await service.search(matching: "swift")

        #expect(firstPage.items.count == 50)
        #expect(firstPage.nextCursor?.bufferedItems.count == 10)
        #expect(firstPage.nextCursor?.nextRepositoriesPage == 3)
        #expect(firstPage.nextCursor?.nextUsersPage == nil)
    }

    @Test
    @MainActor
    func shortQueriesDoNotTriggerSearch() async throws {
        let service = MockGitHubSearchService(firstPagesByQuery: [:])
        let viewModel = GitHubAutocompleteViewModel(
            service: service,
            debounceDuration: .zero,
            sleep: { _ in }
        )

        viewModel.send(.queryChanged("ab"))
        await Task.yield()

        #expect(viewModel.state.items.isEmpty)
        #expect(viewModel.state.viewStatus == .idle)

        let requestedQueries = await service.requestedQueries()
        #expect(requestedQueries.isEmpty)
    }

    @Test
    @MainActor
    func latestQueryWinsWhenInputChangesQuickly() async throws {
        let service = MockGitHubSearchService(
            firstPagesByQuery: [
                "swift": GitHubSearchPage(
                    items: [
                        .repository(
                            GitHubRepository(
                                id: 1,
                                name: "swift",
                                fullName: "apple/swift",
                                htmlURL: URL(string: "https://github.com/apple/swift")!
                            )
                        )
                    ],
                    nextCursor: nil
                ),
                "swiftui": GitHubSearchPage(
                    items: [
                        .user(
                            GitHubUser(
                                id: 2,
                                login: "swiftui",
                                htmlURL: URL(string: "https://github.com/swiftui")!
                            )
                        )
                    ],
                    nextCursor: nil
                )
            ],
            initialDelayByQuery: [
                "swift": .milliseconds(500)
            ]
        )

        let viewModel = GitHubAutocompleteViewModel(
            service: service,
            debounceDuration: .zero,
            sleep: { _ in }
        )

        viewModel.send(.queryChanged("swift"))
        // Wait until "swift" has actually entered service.search (and been recorded)
        // before cancelling it — avoids any timing dependency.
        await service.waitUntilSearchCalled(query: "swift")
        viewModel.send(.queryChanged("swiftui"))
        await viewModel.searchTask?.value

        #expect(viewModel.state.viewStatus == .results)
        #expect(viewModel.state.items.map(\.title) == ["swiftui"])

        let requestedQueries = await service.requestedQueries()
        #expect(requestedQueries.contains("swift"))
        #expect(requestedQueries.contains("swiftui"))
    }

    @Test
    @MainActor
    func debounceDelaysLoadingWhileUserIsStillTyping() async throws {
        let service = MockGitHubSearchService(
            firstPagesByQuery: [
                "swift": GitHubSearchPage(
                    items: [],
                    nextCursor: nil
                )
            ]
        )
        let gate = DebounceGate()

        let viewModel = GitHubAutocompleteViewModel(
            service: service,
            debounceDuration: .milliseconds(300),
            sleep: { _ in
                try await gate.wait()
            }
        )

        viewModel.send(.queryChanged("swift"))
        await Task.yield()

        #expect(viewModel.state.isDebouncing == true)
        #expect(viewModel.state.viewStatus == .idle)

        let requestedQueriesBeforeRelease = await service.requestedQueries()
        #expect(requestedQueriesBeforeRelease.isEmpty)

        await gate.release()
        await viewModel.searchTask?.value

        #expect(viewModel.state.isDebouncing == false)
    }

    @Test
    @MainActor
    func debounceCancelsPreviousPendingInput() async throws {
        let service = MockGitHubSearchService(
            firstPagesByQuery: [
                "swiftui": GitHubSearchPage(
                    items: [
                        .user(
                            GitHubUser(
                                id: 1,
                                login: "swiftui",
                                htmlURL: URL(string: "https://github.com/swiftui")!
                            )
                        )
                    ],
                    nextCursor: nil
                )
            ]
        )
        let gate = DebounceGate()

        let viewModel = GitHubAutocompleteViewModel(
            service: service,
            debounceDuration: .milliseconds(300),
            sleep: { _ in
                try await gate.wait()
            }
        )

        viewModel.send(.queryChanged("swift"))
        await Task.yield()
        viewModel.send(.queryChanged("swiftui"))
        await Task.yield()

        let requestedQueriesBeforeRelease = await service.requestedQueries()
        #expect(requestedQueriesBeforeRelease.isEmpty)
        #expect(viewModel.state.isDebouncing == true)

        await gate.release()
        await viewModel.searchTask?.value

        let requestedQueries = await service.requestedQueries()
        #expect(requestedQueries == ["swiftui"])
        #expect(viewModel.state.items.map(\.title) == ["swiftui"])
    }

    @Test
    @MainActor
    func loadingNextPageAppendsAdditionalResults() async throws {
        let service = MockGitHubSearchService(
            firstPagesByQuery: [
                "swift": GitHubSearchPage(
                    items: [
                        .user(
                            GitHubUser(
                                id: 1,
                                login: "zeta",
                                htmlURL: URL(string: "https://github.com/zeta")!
                            )
                        )
                    ],
                    nextCursor: GitHubSearchCursor(
                        nextUsersPage: 2,
                        nextRepositoriesPage: nil,
                        bufferedItems: []
                    )
                )
            ],
            pagedResultsByRequest: [
                MockPageRequest(
                    query: "swift",
                    cursor: GitHubSearchCursor(
                        nextUsersPage: 2,
                        nextRepositoriesPage: nil,
                        bufferedItems: []
                    )
                ):
                    GitHubSearchPage(
                        items: [
                            .repository(
                                GitHubRepository(
                                    id: 2,
                                    name: "alpha",
                                    fullName: "example/alpha",
                                    htmlURL: URL(string: "https://github.com/example/alpha")!
                                )
                            )
                        ],
                        nextCursor: nil
                    )
            ]
        )

        let viewModel = GitHubAutocompleteViewModel(
            service: service,
            debounceDuration: .zero,
            sleep: { _ in }
        )

        viewModel.send(.queryChanged("swift"))
        await viewModel.searchTask?.value

        viewModel.send(.retryLoadNextPage)
        await viewModel.paginationTask?.value

        #expect(viewModel.state.items.map(\.title) == ["alpha", "zeta"])

        let pageRequests = await service.requestedPageLoads()
        #expect(
            pageRequests == [
                MockPageRequest(
                    query: "swift",
                    cursor: GitHubSearchCursor(
                        nextUsersPage: 2,
                        nextRepositoriesPage: nil,
                        bufferedItems: []
                    )
                )
            ]
        )
    }

    @Test
    @MainActor
    func forbiddenErrorShowsHelpfulRateLimitMessage() async throws {
        let service = FailingGitHubSearchService(error: NetworkRequestError.forbidden)
        let viewModel = GitHubAutocompleteViewModel(
            service: service,
            debounceDuration: .zero,
            sleep: { _ in }
        )

        viewModel.send(.queryChanged("ios"))
        await viewModel.searchTask?.value

        #expect(
            viewModel.state.viewStatus
                == .error(
                    "GitHub temporarily rejected the request. This usually means the search rate limit was reached. Add `GITHUB_TOKEN` to the app scheme environment or try again in a moment."
                )
        )
    }
}

private struct MockGitHubSearchNetworking: GitHubSearchNetworking {
    let usersByPage: [Int: SearchResponse<GitHubUser>]
    let repositoriesByPage: [Int: SearchResponse<GitHubRepository>]

    func fetchUsers(
        matching query: String,
        limit: Int,
        page: Int
    ) async throws -> SearchResponse<GitHubUser> {
        usersByPage[page] ?? SearchResponse(totalCount: 0, items: [])
    }

    func fetchRepositories(
        matching query: String,
        limit: Int,
        page: Int
    ) async throws -> SearchResponse<GitHubRepository> {
        repositoriesByPage[page] ?? SearchResponse(totalCount: 0, items: [])
    }
}

private struct MockPageRequest: Hashable, Equatable {
    let query: String
    let cursor: GitHubSearchCursor
}

private actor DebounceGate {
    private var continuations: [CheckedContinuation<Void, Error>] = []

    func wait() async throws {
        try await withCheckedThrowingContinuation { continuation in
            continuations.append(continuation)
        }
    }

    func release() {
        let pendingContinuations = continuations
        continuations.removeAll()
        pendingContinuations.forEach { $0.resume() }
    }
}

private actor MockGitHubSearchService: GitHubSearchProviding {
    private let firstPagesByQuery: [String: GitHubSearchPage]
    private let pagedResultsByRequest: [MockPageRequest: GitHubSearchPage]
    private let initialDelayByQuery: [String: Duration]
    private var queries: [String] = []
    private var pageRequests: [MockPageRequest] = []
    private var searchCalledContinuations: [String: CheckedContinuation<Void, Never>] = [:]

    init(
        firstPagesByQuery: [String: GitHubSearchPage],
        pagedResultsByRequest: [MockPageRequest: GitHubSearchPage] = [:],
        initialDelayByQuery: [String: Duration] = [:]
    ) {
        self.firstPagesByQuery = firstPagesByQuery
        self.pagedResultsByRequest = pagedResultsByRequest
        self.initialDelayByQuery = initialDelayByQuery
    }

    func search(matching query: String) async throws -> GitHubSearchPage {
        queries.append(query)
        searchCalledContinuations.removeValue(forKey: query)?.resume()

        if let delay = initialDelayByQuery[query] {
            try await Task.sleep(for: delay)
        }

        try Task.checkCancellation()
        return firstPagesByQuery[query, default: .empty]
    }

    func loadNextPage(
        matching query: String,
        cursor: GitHubSearchCursor
    ) async throws -> GitHubSearchPage {
        let request = MockPageRequest(
            query: query,
            cursor: cursor
        )
        pageRequests.append(request)
        try Task.checkCancellation()
        return pagedResultsByRequest[request, default: .empty]
    }

    func requestedQueries() -> [String] {
        queries
    }

    func requestedPageLoads() -> [MockPageRequest] {
        pageRequests
    }

    func waitUntilSearchCalled(query: String) async {
        await withCheckedContinuation { continuation in
            searchCalledContinuations[query] = continuation
        }
    }
}

private struct FailingGitHubSearchService: GitHubSearchProviding {
    let error: Error

    func search(matching query: String) async throws -> GitHubSearchPage {
        throw error
    }

    func loadNextPage(
        matching query: String,
        cursor: GitHubSearchCursor
    ) async throws -> GitHubSearchPage {
        throw error
    }
}

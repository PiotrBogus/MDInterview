import Foundation
import INetwork

struct GitHubSearchService: GitHubSearchProviding {
    private let networking: any GitHubSearchNetworking
    private let resultsLimit: Int
    private let usersBatchLimit: Int
    private let repositoriesBatchLimit: Int

    init(
        networking: any GitHubSearchNetworking,
        resultsLimit: Int = 50
    ) {
        self.networking = networking
        self.resultsLimit = max(1, min(resultsLimit, 50))
        self.usersBatchLimit = max(1, self.resultsLimit / 2)
        self.repositoriesBatchLimit = max(1, self.resultsLimit - self.usersBatchLimit)
    }

    func search(matching query: String) async throws -> GitHubSearchPage {
        let trimmedQuery = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmedQuery.count >= 3 else {
            return .empty
        }

        return try await fetchPage(
            matching: trimmedQuery,
            cursor: GitHubSearchCursor(
                nextUsersPage: 1,
                nextRepositoriesPage: 1,
                bufferedItems: []
            )
        )
    }

    func loadNextPage(
        matching query: String,
        cursor: GitHubSearchCursor
    ) async throws -> GitHubSearchPage {
        let trimmedQuery = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmedQuery.count >= 3 else {
            return .empty
        }
        guard cursor.hasMoreResults else {
            return .empty
        }

        return try await fetchPage(
            matching: trimmedQuery,
            cursor: cursor
        )
    }

    private func fetchPage(
        matching query: String,
        cursor: GitHubSearchCursor
    ) async throws -> GitHubSearchPage {
        var nextUsersPage = cursor.nextUsersPage
        var nextRepositoriesPage = cursor.nextRepositoriesPage
        var collectedItems = cursor.bufferedItems

        while collectedItems.count < resultsLimit && (nextUsersPage != nil || nextRepositoriesPage != nil) {
            let currentUsersPage = nextUsersPage
            let currentRepositoriesPage = nextRepositoriesPage

            async let usersResponseTask: SearchResponse<GitHubUser>? = {
                guard let currentUsersPage else { return nil }
                return try await networking.fetchUsers(
                    matching: query,
                    limit: usersBatchLimit,
                    page: currentUsersPage
                )
            }()

            async let repositoriesResponseTask: SearchResponse<GitHubRepository>? = {
                guard let currentRepositoriesPage else { return nil }
                return try await networking.fetchRepositories(
                    matching: query,
                    limit: repositoriesBatchLimit,
                    page: currentRepositoriesPage
                )
            }()

            let usersResponse = try await usersResponseTask
            let repositoriesResponse = try await repositoriesResponseTask

            if let currentUsersPage, let usersResponse {
                let batchItems = Array(
                    usersResponse.items
                        .map(GitHubAutocompleteItem.user)
                        .sorted { $0.sortKey < $1.sortKey }
                        .prefix(usersBatchLimit)
                )
                collectedItems.append(contentsOf: batchItems)
                nextUsersPage = nextPage(
                    after: currentUsersPage,
                    pageSize: usersBatchLimit,
                    response: usersResponse
                )
            }

            if let currentRepositoriesPage, let repositoriesResponse {
                let batchItems = Array(
                    repositoriesResponse.items
                        .map(GitHubAutocompleteItem.repository)
                        .sorted { $0.sortKey < $1.sortKey }
                        .prefix(repositoriesBatchLimit)
                )
                collectedItems.append(contentsOf: batchItems)
                nextRepositoriesPage = nextPage(
                    after: currentRepositoriesPage,
                    pageSize: repositoriesBatchLimit,
                    response: repositoriesResponse
                )
            }

            if usersResponse?.items.isEmpty != false && repositoriesResponse?.items.isEmpty != false {
                break
            }
        }

        let sortedItems = collectedItems.sorted { $0.sortKey < $1.sortKey }
        let pageItems = Array(sortedItems.prefix(resultsLimit))
        let bufferedItems = Array(sortedItems.dropFirst(resultsLimit))

        let nextCursor = GitHubSearchCursor(
            nextUsersPage: nextUsersPage,
            nextRepositoriesPage: nextRepositoriesPage,
            bufferedItems: bufferedItems
        )

        return GitHubSearchPage(
            items: pageItems,
            nextCursor: nextCursor.hasMoreResults ? nextCursor : nil
        )
    }

    private func nextPage<Item>(
        after currentPage: Int,
        pageSize: Int,
        response: SearchResponse<Item>
    ) -> Int? {
        guard !response.items.isEmpty else { return nil }
        guard currentPage * pageSize < response.totalCount else { return nil }
        return currentPage + 1
    }
}

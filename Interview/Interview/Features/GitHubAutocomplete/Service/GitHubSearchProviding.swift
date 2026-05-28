protocol GitHubSearchProviding: Sendable {
    func search(matching query: String) async throws -> GitHubSearchPage
    func loadNextPage(
        matching query: String,
        cursor: GitHubSearchCursor
    ) async throws -> GitHubSearchPage
}

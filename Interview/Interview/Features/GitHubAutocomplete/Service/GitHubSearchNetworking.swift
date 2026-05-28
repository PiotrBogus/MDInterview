import INetwork

protocol GitHubSearchNetworking: Sendable {
    func fetchUsers(
        matching query: String,
        limit: Int,
        page: Int
    ) async throws -> SearchResponse<GitHubUser>

    func fetchRepositories(
        matching query: String,
        limit: Int,
        page: Int
    ) async throws -> SearchResponse<GitHubRepository>
}

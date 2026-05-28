import Foundation
import INetwork

struct GitHubAPISearchNetworking: GitHubSearchNetworking {
    private let apiClient: APIClient
    private let configuration: GitHubAPIConfiguration

    init(
        apiClient: APIClient,
        configuration: GitHubAPIConfiguration
    ) {
        self.apiClient = apiClient
        self.configuration = configuration
    }

    func fetchUsers(
        matching query: String,
        limit: Int,
        page: Int
    ) async throws -> SearchResponse<GitHubUser> {
        try await apiClient.dispatch(
            GitHubUsersSearchRequest(
                query: query,
                limit: limit,
                page: page,
                configuration: configuration
            )
        )
    }

    func fetchRepositories(
        matching query: String,
        limit: Int,
        page: Int
    ) async throws -> SearchResponse<GitHubRepository> {
        try await apiClient.dispatch(
            GitHubRepositoriesSearchRequest(
                query: query,
                limit: limit,
                page: page,
                configuration: configuration
            )
        )
    }
}

// MARK: - Private request types

private struct GitHubUsersSearchRequest: HTTPRequest {
    typealias ReturnType = SearchResponse<GitHubUser>

    let query: String
    let limit: Int
    let page: Int
    let configuration: GitHubAPIConfiguration
    let path = "/search/users"

    var queryParams: HTTPQueryParams? {
        [
            "q": query,
            "per_page": String(limit),
            "page": String(page)
        ]
    }

    var headers: HTTPHeaders? {
        githubHeaders(configuration: configuration)
    }
}

private struct GitHubRepositoriesSearchRequest: HTTPRequest {
    typealias ReturnType = SearchResponse<GitHubRepository>

    let query: String
    let limit: Int
    let page: Int
    let configuration: GitHubAPIConfiguration
    let path = "/search/repositories"

    var queryParams: HTTPQueryParams? {
        [
            "q": query,
            "per_page": String(limit),
            "page": String(page)
        ]
    }

    var headers: HTTPHeaders? {
        githubHeaders(configuration: configuration)
    }
}

// MARK: - Shared header builder

private func githubHeaders(configuration: GitHubAPIConfiguration) -> HTTPHeaders {
    var headers: HTTPHeaders = [
        HTTPHeaderField.acceptType.rawValue: "application/vnd.github+json",
        "X-GitHub-Api-Version": "2022-11-28",
        "User-Agent": configuration.userAgent
    ]
    if let token = configuration.token {
        headers[HTTPHeaderField.authentication.rawValue] = "Bearer \(token)"
    }
    return headers
}

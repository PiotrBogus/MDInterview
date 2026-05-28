import INetwork

struct AppEngine {
    let gitHubSearchService: any GitHubSearchProviding
    let colorSchemeService: any ColorSchemeServiceProviding
    let tokenStore: any GitHubTokenStoreProviding

    static func live(overrideToken: String? = nil) -> AppEngine {
        AppEngine(
            gitHubSearchService: GitHubSearchService(
                networking: GitHubAPISearchNetworking(
                    apiClient: APIClient(baseURL: "https://api.github.com"),
                    configuration: .live(overrideToken: overrideToken)
                )
            ),
            colorSchemeService: ColorSchemeService(),
            tokenStore: GitHubTokenStore()
        )
    }
}

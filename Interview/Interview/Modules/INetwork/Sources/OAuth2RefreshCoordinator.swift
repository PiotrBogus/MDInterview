import Foundation

actor OAuth2RefreshCoordinator {
    private let tokenStore: any OAuth2TokenStore
    private let tokenRefresher: any OAuth2TokenRefresher
    private var refreshTask: Task<OAuth2Token, Error>?

    init(
        tokenStore: any OAuth2TokenStore,
        tokenRefresher: any OAuth2TokenRefresher
    ) {
        self.tokenStore = tokenStore
        self.tokenRefresher = tokenRefresher
    }

    func refreshToken(using token: OAuth2Token) async throws -> OAuth2Token {
        if let refreshTask {
            return try await refreshTask.value
        }

        let refreshTask = Task {
            let refreshedToken = try await tokenRefresher.refreshToken(using: token)
            await tokenStore.save(token: refreshedToken)
            return refreshedToken
        }

        self.refreshTask = refreshTask
        defer { self.refreshTask = nil }

        return try await refreshTask.value
    }
}

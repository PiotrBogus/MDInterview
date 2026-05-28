import Foundation

public struct OAuth2Interceptor: NetworkInterceptor {
    private let tokenStore: any OAuth2TokenStore
    private let shouldIntercept: @Sendable (URLRequest) -> Bool
    private let refreshCoordinator: OAuth2RefreshCoordinator

    public init(
        tokenStore: any OAuth2TokenStore,
        tokenRefresher: any OAuth2TokenRefresher,
        shouldIntercept: @escaping @Sendable (URLRequest) -> Bool = { _ in true }
    ) {
        self.tokenStore = tokenStore
        self.shouldIntercept = shouldIntercept
        self.refreshCoordinator = OAuth2RefreshCoordinator(
            tokenStore: tokenStore,
            tokenRefresher: tokenRefresher
        )
    }

    public func adapt(_ request: URLRequest) async throws -> URLRequest {
        guard request.requiresAuthorization, shouldIntercept(request) else {
            return unauthorizedRequest(from: request)
        }

        guard let token = await tokenStore.token() else {
            return unauthorizedRequest(from: request)
        }

        return authorizedRequest(from: request, token: token)
    }

    public func retry(
        _ request: URLRequest,
        after response: HTTPURLResponse,
        data: Data
    ) async throws -> URLRequest? {
        guard request.requiresAuthorization, shouldIntercept(request), response.statusCode == 401 else {
            return nil
        }

        guard let storedToken = await tokenStore.token() else {
            return nil
        }

        if request.value(forHTTPHeaderField: HTTPHeaderField.authentication.rawValue)
            != authorizationHeader(for: storedToken) {
            return authorizedRequest(from: request, token: storedToken)
        }

        let refreshedToken = try await refreshCoordinator.refreshToken(using: storedToken)
        return authorizedRequest(from: request, token: refreshedToken)
    }

    private func authorizedRequest(from request: URLRequest, token: OAuth2Token) -> URLRequest {
        var request = request
        request.setValue(
            authorizationHeader(for: token),
            forHTTPHeaderField: HTTPHeaderField.authentication.rawValue
        )
        return request
    }

    private func unauthorizedRequest(from request: URLRequest) -> URLRequest {
        var request = request
        request.setValue(nil, forHTTPHeaderField: HTTPHeaderField.authentication.rawValue)
        return request
    }

    private func authorizationHeader(for token: OAuth2Token) -> String {
        "\(token.tokenType) \(token.accessToken)"
    }
}

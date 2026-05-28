import Foundation

public protocol OAuth2TokenRefresher: Sendable {
    func refreshToken(using token: OAuth2Token) async throws -> OAuth2Token
}

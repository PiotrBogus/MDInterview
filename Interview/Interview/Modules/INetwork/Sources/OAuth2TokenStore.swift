import Foundation

public protocol OAuth2TokenStore: Sendable {
    func token() async -> OAuth2Token?
    func save(token: OAuth2Token?) async
}

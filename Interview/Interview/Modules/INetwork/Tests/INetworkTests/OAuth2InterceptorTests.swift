import Foundation
import XCTest
@testable import JANetwork

final class OAuth2InterceptorTests: XCTestCase {
    override func tearDown() {
        super.tearDown()
        MockURLProtocol.reset()
    }

    func testAdaptAddsBearerTokenFromStore() async throws {
        let store = TestTokenStore(
            token: OAuth2Token(accessToken: "access-token", refreshToken: "refresh-token")
        )
        let interceptor = OAuth2Interceptor(
            tokenStore: store,
            tokenRefresher: TestTokenRefresher { _ in
                XCTFail("Refresh should not be called while adapting a request")
                return OAuth2Token(accessToken: "unused", refreshToken: "unused")
            }
        )

        var request = URLRequest(url: try XCTUnwrap(URL(string: "https://example.com/secure")))
        request.requiresAuthorization = true
        let adaptedRequest = try await interceptor.adapt(request)

        XCTAssertEqual(
            adaptedRequest.value(forHTTPHeaderField: HTTPHeaderField.authentication.rawValue),
            "Bearer access-token"
        )
    }

    func testAdaptSkipsAuthorizationHeaderForPublicRequest() async throws {
        let store = TestTokenStore(
            token: OAuth2Token(accessToken: "access-token", refreshToken: "refresh-token")
        )
        let interceptor = OAuth2Interceptor(
            tokenStore: store,
            tokenRefresher: TestTokenRefresher { _ in
                XCTFail("Refresh should not be called for a public request")
                return OAuth2Token(accessToken: "unused", refreshToken: "unused")
            }
        )

        var request = URLRequest(url: try XCTUnwrap(URL(string: "https://example.com/public")))
        request.requiresAuthorization = false
        request.setValue(
            "Bearer should-be-removed",
            forHTTPHeaderField: HTTPHeaderField.authentication.rawValue
        )

        let adaptedRequest = try await interceptor.adapt(request)

        XCTAssertNil(
            adaptedRequest.value(forHTTPHeaderField: HTTPHeaderField.authentication.rawValue)
        )
    }

    func testDispatchRefreshesTokenAfter401AndRetriesRequest() async throws {
        let store = TestTokenStore(
            token: OAuth2Token(accessToken: "expired-token", refreshToken: "refresh-token")
        )
        let refreshCounter = LockedBox(0)
        let requestHeaders = LockedBox<[String]>([])
        let interceptor = OAuth2Interceptor(
            tokenStore: store,
            tokenRefresher: TestTokenRefresher { token in
                XCTAssertEqual(token.accessToken, "expired-token")
                XCTAssertEqual(token.refreshToken, "refresh-token")
                refreshCounter.withLock { $0 += 1 }
                return OAuth2Token(accessToken: "fresh-token", refreshToken: "next-refresh-token")
            }
        )
        let session = makeURLSession()
        let dispatcher = NetworkDispatcher(urlSession: session, interceptors: [interceptor])
        let client = APIClient(baseURL: "https://example.com", networkDispatcher: dispatcher)

        MockURLProtocol.setHandler { request in
            let authorizationHeader = request.value(
                forHTTPHeaderField: HTTPHeaderField.authentication.rawValue
            ) ?? "missing"
            requestHeaders.withLock { $0.append(authorizationHeader) }

            if authorizationHeader == "Bearer expired-token" {
                return (
                    HTTPURLResponse(
                        url: try XCTUnwrap(request.url),
                        statusCode: 401,
                        httpVersion: nil,
                        headerFields: nil
                    )!,
                    Data()
                )
            }

            if authorizationHeader == "Bearer fresh-token" {
                return (
                    HTTPURLResponse(
                        url: try XCTUnwrap(request.url),
                        statusCode: 200,
                        httpVersion: nil,
                        headerFields: nil
                    )!,
                    #"{"value":"ok"}"#.data(using: .utf8)!
                )
            }

            throw URLError(.userAuthenticationRequired)
        }

        let response = try await client.dispatch(SecureRequest())

        XCTAssertEqual(response, .init(value: "ok"))
        XCTAssertEqual(refreshCounter.value, 1)
        XCTAssertEqual(
            requestHeaders.value,
            ["Bearer expired-token", "Bearer fresh-token"]
        )
        let storedToken = await store.token()
        XCTAssertEqual(storedToken?.accessToken, "fresh-token")
        XCTAssertEqual(storedToken?.refreshToken, "next-refresh-token")
    }

    private func makeURLSession() -> URLSession {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [MockURLProtocol.self]
        return URLSession(configuration: configuration)
    }
}

private struct SecureRequest: HTTPRequest {
    typealias ReturnType = SecureResponse

    let path = "/secure"
    let requiresAuthorization = true
}

private struct SecureResponse: Codable, Equatable {
    let value: String
}

private actor TestTokenStore: OAuth2TokenStore {
    private var currentToken: OAuth2Token?

    init(token: OAuth2Token?) {
        self.currentToken = token
    }

    func token() async -> OAuth2Token? {
        currentToken
    }

    func save(token: OAuth2Token?) async {
        currentToken = token
    }
}

private struct TestTokenRefresher: OAuth2TokenRefresher {
    let refresh: @Sendable (OAuth2Token) async throws -> OAuth2Token

    init(refresh: @escaping @Sendable (OAuth2Token) async throws -> OAuth2Token) {
        self.refresh = refresh
    }

    func refreshToken(using token: OAuth2Token) async throws -> OAuth2Token {
        try await refresh(token)
    }
}

private final class MockURLProtocol: URLProtocol, @unchecked Sendable {
    typealias Handler = (URLRequest) throws -> (HTTPURLResponse, Data)

    private static let lock = NSLock()
    nonisolated(unsafe) private static var handler: Handler?

    static func setHandler(_ handler: @escaping Handler) {
        lock.lock()
        defer { lock.unlock() }
        self.handler = handler
    }

    static func reset() {
        lock.lock()
        defer { lock.unlock() }
        handler = nil
    }

    override class func canInit(with request: URLRequest) -> Bool {
        true
    }

    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        request
    }

    override func startLoading() {
        guard let handler = Self.currentHandler() else {
            client?.urlProtocol(self, didFailWithError: URLError(.badServerResponse))
            return
        }

        do {
            let (response, data) = try handler(request)
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            client?.urlProtocol(self, didLoad: data)
            client?.urlProtocolDidFinishLoading(self)
        } catch {
            client?.urlProtocol(self, didFailWithError: error)
        }
    }

    override func stopLoading() {}

    private static func currentHandler() -> Handler? {
        lock.lock()
        defer { lock.unlock() }
        return handler
    }
}

private final class LockedBox<Value>: @unchecked Sendable {
    private let lock = NSLock()
    private var storage: Value

    init(_ value: Value) {
        self.storage = value
    }

    var value: Value {
        lock.lock()
        defer { lock.unlock() }
        return storage
    }

    func withLock(_ update: (inout Value) -> Void) {
        lock.lock()
        defer { lock.unlock() }
        update(&storage)
    }
}

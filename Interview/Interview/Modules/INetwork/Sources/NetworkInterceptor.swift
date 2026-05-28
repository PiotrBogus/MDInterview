import Foundation

public protocol NetworkInterceptor {
    func adapt(_ request: URLRequest) async throws -> URLRequest
    func retry(
        _ request: URLRequest,
        after response: HTTPURLResponse,
        data: Data
    ) async throws -> URLRequest?
}

public extension NetworkInterceptor {
    func adapt(_ request: URLRequest) async throws -> URLRequest {
        request
    }

    func retry(
        _ request: URLRequest,
        after response: HTTPURLResponse,
        data: Data
    ) async throws -> URLRequest? {
        nil
    }
}

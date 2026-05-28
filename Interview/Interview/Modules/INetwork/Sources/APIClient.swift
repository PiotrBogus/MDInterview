import Foundation

public struct APIClient {
    var baseURL: String!
    var networkDispatcher: NetworkDispatcher!
    
    public init(
        baseURL: String,
        networkDispatcher: NetworkDispatcher = NetworkDispatcher()
    ) {
        self.baseURL = baseURL
        self.networkDispatcher = networkDispatcher
    }
    
    public func dispatch<Request: HTTPRequest>(_ request: Request) async throws -> Request.ReturnType {
        guard let urlRequest = request.asURLRequest(baseURL: baseURL) else {
            throw NetworkRequestError.badRequest
        }
        
        return try await networkDispatcher.dispatch(request: urlRequest, decoder: request.decoder)
    }
}

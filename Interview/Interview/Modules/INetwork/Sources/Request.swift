import Foundation

public typealias HTTPParams = [String: Any]
public typealias HTTPQueryParams = [String: String?]
public typealias HTTPHeaders = [String: String]

public enum HTTPContentType: String {
    case json = "application/json"
}

public enum HTTPHeaderField: String {
    case authentication = "Authorization"
    case contentType = "Content-Type"
    case acceptType = "Accept"
    case acceptEncoding = "Accept-Encoding"
}

public enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
    case patch = "PATCH"
}

public protocol HTTPRequest {
    associatedtype ReturnType: Codable
    var path: String { get }
    var method: HTTPMethod { get }
    var contentType: HTTPContentType { get }
    var queryParams: HTTPQueryParams? { get }
    var body: HTTPParams? { get }
    var headers: HTTPHeaders? { get }
    var decoder: JSONDecoder? { get }
    var requiresAuthorization: Bool { get }
}
 
public extension HTTPRequest {
    var method: HTTPMethod { return .get }
    var contentType: HTTPContentType { return .json }
    var queryParams: HTTPQueryParams? { return nil }
    var body: HTTPParams? { return nil }
    var headers: HTTPHeaders? { return nil }
    var debug: Bool { return false }
    var decoder: JSONDecoder? { return JSONDecoder() }
    var requiresAuthorization: Bool { return false }
}

extension HTTPRequest {
    func asURLRequest(baseURL: String) -> URLRequest? {
        guard var urlComponents = URLComponents(string: baseURL) else { return nil }
        
        urlComponents.path = "\(urlComponents.path)\(path)"
        urlComponents.queryItems = queryItemsFrom()
        
        guard let finalURL = urlComponents.url else { return nil }
        
        var request = URLRequest(url: finalURL)
        request.httpMethod = method.rawValue
        request.httpBody = requestBodyFrom(params: body)
        let defaultHeaders: HTTPHeaders = [
            HTTPHeaderField.contentType.rawValue: contentType.rawValue,
            HTTPHeaderField.acceptType.rawValue: contentType.rawValue
        ]
        request.allHTTPHeaderFields = defaultHeaders.merging(headers ?? [:], uniquingKeysWith: { _, second in second })
        request.requiresAuthorization = requiresAuthorization
        return request
    }
    
    private func requestBodyFrom(params: HTTPParams?) -> Data? {
        guard let params = params else { return nil }
        guard let httpBody = try? JSONSerialization.data(withJSONObject: params, options: []) else {
            return nil
        }
        return httpBody
    }
    
    private func queryItemsFrom() -> [URLQueryItem]? {
        guard let params = queryParams else { return nil }
        return params.map {
            URLQueryItem(name: $0.key, value: $0.value)
        }
    }
}

extension URLRequest {
    private static let requiresAuthorizationKey = "com.jutro.network.requiresAuthorization"

    var requiresAuthorization: Bool {
        get {
            URLProtocol.property(
                forKey: Self.requiresAuthorizationKey,
                in: self
            ) as? Bool ?? false
        }
        set {
            let mutableRequest = (self as NSURLRequest).mutableCopy() as! NSMutableURLRequest
            URLProtocol.setProperty(
                newValue,
                forKey: Self.requiresAuthorizationKey,
                in: mutableRequest
            )
            self = mutableRequest as URLRequest
        }
    }
}

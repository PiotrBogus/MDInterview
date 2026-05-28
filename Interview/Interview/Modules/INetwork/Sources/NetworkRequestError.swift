import Foundation

public enum NetworkRequestError: LocalizedError, Equatable {
    case invalidRequest
    case badRequest
    case unauthorized
    case forbidden
    case notFound
    case error4xx(_ code: Int)
    case serverError
    case error5xx(_ code: Int)
    case decodingError
    case urlSessionFailed(_ error: URLError)
    case unknownError
}

public extension NetworkRequestError {
    var errorDescription: String? {
        switch self {
        case .invalidRequest:
            return "Invalid request."
        case .badRequest:
            return "Bad request."
        case .unauthorized:
            return "Unauthorized."
        case .forbidden:
            return "Forbidden."
        case .notFound:
            return "Not found."
        case .error4xx(let code):
            return "Request failed with status code \(code)."
        case .serverError:
            return "Server error."
        case .error5xx(let code):
            return "Server failed with status code \(code)."
        case .decodingError:
            return "Failed to decode server response."
        case .urlSessionFailed(let error):
            return error.localizedDescription
        case .unknownError:
            return "Unknown error."
        }
    }
}

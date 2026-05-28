import Foundation

public struct NetworkDispatcher {
    private static let requestDeduplicator = NetworkRequestDeduplicator()

    let urlSession: URLSession!
    let interceptors: [any NetworkInterceptor]
    
    public init(
        urlSession: URLSession = .shared,
        interceptors: [any NetworkInterceptor] = []
    ) {
        self.urlSession = urlSession
        self.interceptors = interceptors
    }
    
    public func dispatch<ReturnType: Codable>(request: URLRequest, decoder: JSONDecoder?) async throws -> ReturnType {
        let decoder = decoder ?? JSONDecoder()

        do {
            var requestToDispatch = request
            var hasRetried = false

            while true {
                let interceptedRequest = try await adapt(request: requestToDispatch)
                let (data, response) = try await perform(interceptedRequest)

                if let response = response as? HTTPURLResponse,
                   !(200...299).contains(response.statusCode) {
                    if !hasRetried,
                       let retryRequest = try await retry(
                        request: interceptedRequest,
                        after: response,
                        data: data
                       ) {
                        hasRetried = true
                        requestToDispatch = retryRequest
                        continue
                    }

                    throw httpError(response.statusCode)
                }

                NetworkLogger.logResponse(data: data, response: response, request: interceptedRequest)

                let responseData: Data
                if data.isEmpty && ReturnType.self is NoReply.Type {
                    responseData = #"{"title": "empty"}"#.data(using: .utf8)!
                } else {
                    responseData = data
                }

                return try decoder.decode(ReturnType.self, from: responseData)
            }
        } catch {
            NetworkLogger.logError(error, for: request)
            throw handleError(error)
        }
    }

    private func adapt(request: URLRequest) async throws -> URLRequest {
        var adaptedRequest = request

        for interceptor in interceptors {
            adaptedRequest = try await interceptor.adapt(adaptedRequest)
        }

        return adaptedRequest
    }

    private func retry(
        request: URLRequest,
        after response: HTTPURLResponse,
        data: Data
    ) async throws -> URLRequest? {
        for interceptor in interceptors {
            if let retryRequest = try await interceptor.retry(
                request,
                after: response,
                data: data
            ) {
                return retryRequest
            }
        }

        return nil
    }

    private func perform(_ request: URLRequest) async throws -> (Data, URLResponse) {
        let requestKey = request.deduplicationKey
        let urlSession = self.urlSession!

        let inFlightRequest = await Self.requestDeduplicator.task(for: requestKey) {
            Task {
                try await urlSession.data(for: request)
            }
        }

        do {
            let result = try await inFlightRequest.task.value
            if inFlightRequest.isOwner {
                await Self.requestDeduplicator.finish(key: requestKey)
            }
            return result
        } catch {
            if inFlightRequest.isOwner {
                await Self.requestDeduplicator.finish(key: requestKey)
            }
            throw error
        }
    }
    
    private func httpError(_ statusCode: Int) -> NetworkRequestError {
        switch statusCode {
            case 400: return .badRequest
            case 401: return .unauthorized
            case 403: return .forbidden
            case 404: return .notFound
            case 402, 405...499: return .error4xx(statusCode)
            case 500: return .serverError
            case 501...599: return .error5xx(statusCode)
            default: return .unknownError
        }
    }
    
    private func handleError(_ error: Error) -> NetworkRequestError {
        print(error)
        switch error {
        case is Swift.DecodingError:
            return .decodingError
        case let urlError as URLError:
            return .urlSessionFailed(urlError)
        case let error as NetworkRequestError:
            return error
        default:
            return .unknownError
        }
    }
}

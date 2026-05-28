import Foundation

public struct CURLLoggingInterceptor: NetworkInterceptor {
    public init() {}

    public func adapt(_ request: URLRequest) async throws -> URLRequest {
        #if DEBUG
        print(curlString(from: request))
        #endif

        return request
    }

    private func curlString(from request: URLRequest) -> String {
        guard let url = request.url else {
            return "curl command could not be generated: missing URL"
        }

        var components = ["curl"]

        if let method = request.httpMethod, method != "GET" {
            components.append("-X \(shellEscaped(method))")
        }

        let headers = request.allHTTPHeaderFields ?? [:]
        for key in headers.keys.sorted() {
            if let value = headers[key] {
                components.append("-H \(shellEscaped("\(key): \(value)"))")
            }
        }

        if let body = request.httpBody, !body.isEmpty {
            let bodyString = String(decoding: body, as: UTF8.self)
            components.append("--data \(shellEscaped(bodyString))")
        }

        components.append(shellEscaped(url.absoluteString))

        return components.joined(separator: " ")
    }

    private func shellEscaped(_ value: String) -> String {
        "'" + value.replacingOccurrences(of: "'", with: "'\\''") + "'"
    }
}

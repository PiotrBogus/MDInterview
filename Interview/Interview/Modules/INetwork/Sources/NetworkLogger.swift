import Foundation

enum NetworkLogger {
    static func logResponse(data: Data, response: URLResponse, request: URLRequest) {
        #if DEBUG
        let requestDescription = describe(request: request)

        if let httpResponse = response as? HTTPURLResponse {
            print(
                """
                [NETWORK RESPONSE]
                Request: \(requestDescription)
                Status: \(httpResponse.statusCode)
                Response: \(string(from: data))
                """
            )
        } else {
            print(
                """
                [NETWORK RESPONSE]
                Request: \(requestDescription)
                Response: \(string(from: data))
                """
            )
        }
        #endif
    }

    static func logError(_ error: Error, for request: URLRequest) {
        #if DEBUG
        print(
            """
            [NETWORK ERROR]
            Request: \(describe(request: request))
            Error: \(error)
            """
        )
        #endif
    }

    private static func describe(request: URLRequest) -> String {
        let method = request.httpMethod ?? "GET"
        let url = request.url?.absoluteString ?? "unknown-url"
        return "\(method) \(url)"
    }

    private static func string(from data: Data) -> String {
        guard !data.isEmpty else { return "<empty>" }
        return String(data: data, encoding: .utf8) ?? "<non-utf8-data size=\(data.count)>"
    }
}

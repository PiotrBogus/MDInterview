import Foundation

actor NetworkRequestDeduplicator {
    private var inFlightRequests: [String: Task<(Data, URLResponse), Error>] = [:]

    func task(
        for key: String,
        create: @Sendable () -> Task<(Data, URLResponse), Error>
    ) -> (task: Task<(Data, URLResponse), Error>, isOwner: Bool) {
        if let existingTask = inFlightRequests[key] {
            return (existingTask, false)
        }

        let task = create()
        inFlightRequests[key] = task
        return (task, true)
    }

    func finish(key: String) {
        inFlightRequests.removeValue(forKey: key)
    }
}

extension URLRequest {
    var deduplicationKey: String {
        let method = httpMethod ?? "GET"
        let urlString = url?.absoluteString ?? "unknown-url"
        let headers = (allHTTPHeaderFields ?? [:])
            .sorted { $0.key < $1.key }
            .map { "\($0.key)=\($0.value)" }
            .joined(separator: "&")
        let body = httpBody?.base64EncodedString() ?? ""

        return "\(method)|\(urlString)|\(headers)|\(body)"
    }
}

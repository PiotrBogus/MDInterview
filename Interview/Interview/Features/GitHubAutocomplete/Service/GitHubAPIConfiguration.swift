import Foundation

struct GitHubAPIConfiguration: Sendable {
    let userAgent: String
    let token: String?

    static func live(overrideToken: String? = nil) -> GitHubAPIConfiguration {
        let bundle = Bundle.main
        let appName = (bundle.object(forInfoDictionaryKey: "CFBundleName") as? String) ?? "InterviewApp"
        let appVersion = (bundle.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String) ?? "1.0"

        let envToken: String? = {
            let environment = ProcessInfo.processInfo.environment
            let candidate = environment["GITHUB_TOKEN"] ?? environment["GITHUB_API_TOKEN"]
            let trimmed = candidate?.trimmingCharacters(in: .whitespacesAndNewlines)
            return trimmed?.isEmpty == false ? trimmed : nil
        }()

        return GitHubAPIConfiguration(
            userAgent: "\(appName)/\(appVersion)",
            token: overrideToken ?? envToken
        )
    }
}

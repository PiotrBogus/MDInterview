import Foundation
import XCTest
@testable import JANetwork

final class HTTPRequestTests: XCTestCase {
    func testAsURLRequestBuildsRequestWithExpectedValues() throws {
        let request = ExampleRequest()

        let urlRequest = try XCTUnwrap(
            request.asURLRequest(baseURL: "https://example.com/api")
        )

        XCTAssertEqual(
            urlRequest.url?.absoluteString,
            "https://example.com/api/users?page=1"
        )
        XCTAssertEqual(urlRequest.httpMethod, HTTPMethod.post.rawValue)
        XCTAssertEqual(
            urlRequest.value(forHTTPHeaderField: HTTPHeaderField.contentType.rawValue),
            HTTPContentType.json.rawValue
        )
        XCTAssertEqual(
            urlRequest.value(forHTTPHeaderField: "X-Test"),
            "1"
        )
        XCTAssertFalse(urlRequest.requiresAuthorization)

        let body = try XCTUnwrap(urlRequest.httpBody)
        let jsonObject = try XCTUnwrap(
            JSONSerialization.jsonObject(with: body) as? [String: String]
        )
        XCTAssertEqual(jsonObject["name"], "Jane")
    }

    func testAsURLRequestStoresOAuth2AuthorizationRequirement() throws {
        let request = AuthorizedExampleRequest()

        let urlRequest = try XCTUnwrap(
            request.asURLRequest(baseURL: "https://example.com/api")
        )

        XCTAssertTrue(urlRequest.requiresAuthorization)
    }
}

private struct ExampleRequest: HTTPRequest {
    typealias ReturnType = NoReply

    let path = "/users"
    let method: HTTPMethod = .post
    let queryParams: HTTPQueryParams? = ["page": "1"]
    let body: HTTPParams? = ["name": "Jane"]
    let headers: HTTPHeaders? = ["X-Test": "1"]
}

private struct AuthorizedExampleRequest: HTTPRequest {
    typealias ReturnType = NoReply

    let path = "/secure"
    let requiresAuthorization = true
}

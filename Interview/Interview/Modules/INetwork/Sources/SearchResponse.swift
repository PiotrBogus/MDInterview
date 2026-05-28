public struct SearchResponse<Item: Codable>: Codable, Sendable where Item: Sendable {
    public let totalCount: Int
    public let items: [Item]

    public init(totalCount: Int, items: [Item]) {
        self.totalCount = totalCount
        self.items = items
    }

    enum CodingKeys: String, CodingKey {
        case totalCount = "total_count"
        case items
    }
}

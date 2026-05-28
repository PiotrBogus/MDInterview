import Foundation

enum GitHubAutocompleteItem: Identifiable, Hashable, Sendable {
    case repository(GitHubRepository)
    case user(GitHubUser)

    var id: String {
        switch self {
        case .repository(let repository):
            return "repository-\(repository.id)"
        case .user(let user):
            return "user-\(user.id)"
        }
    }

    var title: String {
        switch self {
        case .repository(let repository):
            return repository.name
        case .user(let user):
            return user.login
        }
    }

    var subtitle: String {
        switch self {
        case .repository(let repository):
            return repository.fullName
        case .user(let user):
            return user.htmlURL.absoluteString
        }
    }

    var systemImageName: String {
        switch self {
        case .repository:
            return "folder"
        case .user:
            return "person.crop.circle"
        }
    }

    var sortKey: String {
        title.lowercased()
    }
}

struct GitHubRepository: Codable, Hashable, Sendable {
    let id: Int
    let name: String
    let fullName: String
    let htmlURL: URL

    nonisolated init(id: Int, name: String, fullName: String, htmlURL: URL) {
        self.id = id
        self.name = name
        self.fullName = fullName
        self.htmlURL = htmlURL
    }

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case fullName = "full_name"
        case htmlURL = "html_url"
    }

    nonisolated init(from decoder: any Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        id       = try c.decode(Int.self,    forKey: .id)
        name     = try c.decode(String.self, forKey: .name)
        fullName = try c.decode(String.self, forKey: .fullName)
        htmlURL  = try c.decode(URL.self,    forKey: .htmlURL)
    }

    nonisolated func encode(to encoder: any Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        try c.encode(id,       forKey: .id)
        try c.encode(name,     forKey: .name)
        try c.encode(fullName, forKey: .fullName)
        try c.encode(htmlURL,  forKey: .htmlURL)
    }
}

struct GitHubUser: Codable, Hashable, Sendable {
    let id: Int
    let login: String
    let htmlURL: URL

    nonisolated init(id: Int, login: String, htmlURL: URL) {
        self.id = id
        self.login = login
        self.htmlURL = htmlURL
    }

    enum CodingKeys: String, CodingKey {
        case id
        case login
        case htmlURL = "html_url"
    }

    nonisolated init(from decoder: any Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        id      = try c.decode(Int.self,    forKey: .id)
        login   = try c.decode(String.self, forKey: .login)
        htmlURL = try c.decode(URL.self,    forKey: .htmlURL)
    }

    nonisolated func encode(to encoder: any Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        try c.encode(id,      forKey: .id)
        try c.encode(login,   forKey: .login)
        try c.encode(htmlURL, forKey: .htmlURL)
    }
}

struct GitHubSearchCursor: Hashable, Sendable {
    let nextUsersPage: Int?
    let nextRepositoriesPage: Int?
    let bufferedItems: [GitHubAutocompleteItem]

    var hasMoreResults: Bool {
        nextUsersPage != nil || nextRepositoriesPage != nil || !bufferedItems.isEmpty
    }
}

struct GitHubSearchPage: Equatable {
    let items: [GitHubAutocompleteItem]
    let nextCursor: GitHubSearchCursor?

    var hasMoreUsers: Bool {
        nextCursor?.nextUsersPage != nil
    }

    var hasMoreRepositories: Bool {
        nextCursor?.nextRepositoriesPage != nil
    }

    var hasMoreResults: Bool {
        nextCursor?.hasMoreResults == true
    }

    static let empty = GitHubSearchPage(
        items: [],
        nextCursor: nil
    )
}

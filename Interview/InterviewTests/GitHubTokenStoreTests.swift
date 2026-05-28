import Testing
@testable import Interview

@Suite("GitHubTokenStore", .serialized)
struct GitHubTokenStoreTests {

    init() {
        GitHubTokenStore().completeSetup(token: nil)
    }

    // MARK: - Read when empty

    @Test
    func tokenIsNilWhenNothingStored() {
        let store = GitHubTokenStore()

        #expect(store.token == nil)
    }

    // MARK: - Save and read

    @Test
    func completeSetupStoresToken() {
        let store = GitHubTokenStore()

        store.completeSetup(token: "ghp_abc123")

        #expect(store.token == "ghp_abc123")
    }

    @Test
    func tokenIsReadableFromSeparateInstance() {
        GitHubTokenStore().completeSetup(token: "ghp_persistent")

        #expect(GitHubTokenStore().token == "ghp_persistent")
    }

    @Test
    func completeSetupUpdatesExistingToken() {
        let store = GitHubTokenStore()
        store.completeSetup(token: "ghp_first")

        store.completeSetup(token: "ghp_second")

        #expect(store.token == "ghp_second")
    }

    // MARK: - Whitespace trimming

    @Test
    func completeSetupTrimsLeadingAndTrailingWhitespace() {
        let store = GitHubTokenStore()

        store.completeSetup(token: "  ghp_abc  ")

        #expect(store.token == "ghp_abc")
    }

    @Test
    func completeSetupTrimsNewlinesAndTabs() {
        let store = GitHubTokenStore()

        store.completeSetup(token: "\n\tghp_abc\n")

        #expect(store.token == "ghp_abc")
    }

    // MARK: - Deletion

    @Test
    func completeSetupWithNilRemovesToken() {
        let store = GitHubTokenStore()
        store.completeSetup(token: "ghp_abc")

        store.completeSetup(token: nil)

        #expect(store.token == nil)
    }

    @Test
    func completeSetupWithWhitespaceOnlyRemovesToken() {
        let store = GitHubTokenStore()
        store.completeSetup(token: "ghp_abc")

        store.completeSetup(token: "   ")

        #expect(store.token == nil)
    }

    @Test
    func completeSetupWithNilIsNoopWhenNothingStored() {
        let store = GitHubTokenStore()

        store.completeSetup(token: nil)

        #expect(store.token == nil)
    }

    @Test
    func tokenRemainsNilAfterDeletingTwice() {
        let store = GitHubTokenStore()
        store.completeSetup(token: "ghp_abc")
        store.completeSetup(token: nil)

        store.completeSetup(token: nil)

        #expect(store.token == nil)
    }
}

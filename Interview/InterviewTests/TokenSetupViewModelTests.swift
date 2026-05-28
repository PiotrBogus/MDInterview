import Testing
@testable import Interview

@Suite("TokenSetupViewModel")
@MainActor
struct TokenSetupViewModelTests {

    // MARK: - Initial state

    @Test
    func initialTokenPrefillsInput() {
        let viewModel = TokenSetupViewModel(initialToken: "ghp_abc123") { _ in }

        #expect(viewModel.tokenInput == "ghp_abc123")
    }

    @Test
    func missingInitialTokenLeavesInputEmpty() {
        let viewModel = TokenSetupViewModel { _ in }

        #expect(viewModel.tokenInput == "")
    }

    @Test
    func nilInitialTokenLeavesInputEmpty() {
        let viewModel = TokenSetupViewModel(initialToken: nil) { _ in }

        #expect(viewModel.tokenInput == "")
    }

    @Test
    func tokenVisibilityStartsHidden() {
        let viewModel = TokenSetupViewModel { _ in }

        #expect(viewModel.isTokenVisible == false)
    }

    // MARK: - canSave

    @Test
    func canSaveIsFalseWhenInputIsEmpty() {
        let viewModel = TokenSetupViewModel { _ in }

        #expect(viewModel.canSave == false)
    }

    @Test
    func canSaveIsTrueWhenInputHasText() {
        let viewModel = TokenSetupViewModel(initialToken: "ghp_abc") { _ in }

        #expect(viewModel.canSave == true)
    }

    @Test
    func canSaveIsFalseForWhitespaceOnlyInput() {
        let viewModel = TokenSetupViewModel(initialToken: "   ") { _ in }

        #expect(viewModel.canSave == false)
    }

    @Test
    func canSaveIsFalseForNewlineOnlyInput() {
        let viewModel = TokenSetupViewModel(initialToken: "\n\t") { _ in }

        #expect(viewModel.canSave == false)
    }

    @Test
    func canSaveBecomesTrue_whenUserTypesToken() {
        let viewModel = TokenSetupViewModel { _ in }

        viewModel.tokenInput = "ghp_token"

        #expect(viewModel.canSave == true)
    }

    @Test
    func canSaveBecomesFalse_whenUserClearsInput() {
        let viewModel = TokenSetupViewModel(initialToken: "ghp_token") { _ in }

        viewModel.tokenInput = ""

        #expect(viewModel.canSave == false)
    }

    // MARK: - save

    @Test
    func saveCallsOnCompleteWithTrimmedToken() {
        var received: String?
        let viewModel = TokenSetupViewModel(initialToken: "  ghp_abc  ") { received = $0 }

        viewModel.save()

        #expect(received == "ghp_abc")
    }

    @Test
    func savePassesTokenWithoutModifyingContent() {
        var received: String?
        let viewModel = TokenSetupViewModel(initialToken: "ghp_abc123xyz") { received = $0 }

        viewModel.save()

        #expect(received == "ghp_abc123xyz")
    }

    @Test
    func saveTrimsLeadingAndTrailingWhitespace() {
        var received: String?
        let viewModel = TokenSetupViewModel { received = $0 }
        viewModel.tokenInput = "\n  ghp_token  \t"

        viewModel.save()

        #expect(received == "ghp_token")
    }

    // MARK: - skip

    @Test
    func skipCallsOnCompleteWithNil() {
        var received: String? = "sentinel"
        let viewModel = TokenSetupViewModel(initialToken: "ghp_abc") { received = $0 }

        viewModel.skip()

        #expect(received == nil)
    }

    @Test
    func skipIgnoresCurrentInput() {
        var received: String? = "sentinel"
        let viewModel = TokenSetupViewModel { received = $0 }
        viewModel.tokenInput = "ghp_token"

        viewModel.skip()

        #expect(received == nil)
    }

    // MARK: - isTokenVisible

    @Test
    func togglingIsTokenVisibleShowsAndHidesToken() {
        let viewModel = TokenSetupViewModel { _ in }

        viewModel.isTokenVisible = true
        #expect(viewModel.isTokenVisible == true)

        viewModel.isTokenVisible = false
        #expect(viewModel.isTokenVisible == false)
    }
}

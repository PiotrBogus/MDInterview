import Foundation

// MARK: - String keys

/// Type-safe access to all localized strings defined in Localizable.xcstrings.
/// Each nested enum mirrors a key namespace (e.g. `app.hero.badge` → `Strings.App.Hero.badge`).
enum Strings {

    // MARK: App

    enum App {

        enum Hero {
            /// "Native Autocomplete Demo"
            static let badge    = NSLocalizedString("app.hero.badge",    comment: "Small badge label above the main hero title on the home screen")
            /// "Search GitHub users and repositories in one elegant flow."
            static let title    = NSLocalizedString("app.hero.title",    comment: "Main headline in the hero section on the home screen")
            /// "Reusable component with debounce, pagination, and dark mode."
            static let subtitle = NSLocalizedString("app.hero.subtitle", comment: "Supporting subtitle below the main hero headline")
        }

        enum Search {
            /// "GitHub Search"
            static let title = NSLocalizedString("app.search.title", comment: "Title passed to the GitHub search card")
        }

        enum Selected {
            /// "Selected Result"
            static let label   = NSLocalizedString("app.selected.label",   comment: "Label in the selected-result card")
            /// "Dismiss"
            static let dismiss = NSLocalizedString("app.selected.dismiss", comment: "Accessibility label for the dismiss button on the selected-result card")
        }
    }

    // MARK: Settings

    enum Settings {

        /// "Settings"
        static let title = NSLocalizedString("settings.title", comment: "Navigation title for the Settings screen")

        enum Appearance {
            /// "Appearance"
            static let section = NSLocalizedString("settings.appearance.section", comment: "Section header for the appearance picker in Settings")
            /// "System"
            static let system  = NSLocalizedString("settings.appearance.system",  comment: "Label for the System color scheme option in Settings")
            /// "Light"
            static let light   = NSLocalizedString("settings.appearance.light",   comment: "Label for the Light color scheme option in Settings")
            /// "Dark"
            static let dark    = NSLocalizedString("settings.appearance.dark",    comment: "Label for the Dark color scheme option in Settings")
        }
    }

    // MARK: Token Setup

    enum TokenSetup {

        enum Header {
            /// "Optional Setup"
            static let badge    = NSLocalizedString("token_setup.header.badge",    comment: "Small badge label in the token setup card header")
            /// "GitHub Token"
            static let title    = NSLocalizedString("token_setup.header.title",    comment: "Title of the token setup card")
            /// "Add a Personal Access Token to raise your API rate limit. You can skip this step — the app works without one."
            static let subtitle = NSLocalizedString("token_setup.header.subtitle", comment: "Subtitle explaining what the token is for and that it is optional")
        }

        enum Field {
            /// "ghp_••••••••••••"
            static let placeholder = NSLocalizedString("token_setup.field.placeholder", comment: "Placeholder inside the token input field")
            /// "Generate at github.com → Settings → Developer settings → Personal access tokens"
            static let hint        = NSLocalizedString("token_setup.field.hint",        comment: "Caption below the token field telling the user where to generate the token")
        }

        enum Actions {
            /// "Add Token"
            static let save = NSLocalizedString("token_setup.actions.save", comment: "Primary button label that saves the entered token")
            /// "Skip for now"
            static let skip = NSLocalizedString("token_setup.actions.skip", comment: "Secondary button label that skips token setup")
        }
    }

    // MARK: GitHub Search

    enum GitHubSearch {

        enum Header {
            /// "Unified GitHub Lookup"
            static let badge    = NSLocalizedString("github_search.header.badge",    comment: "Small badge label inside the GitHub search card header")
            /// "Search repositories and users in one stream."
            static let subtitle = NSLocalizedString("github_search.header.subtitle", comment: "Subtitle below the section title inside the GitHub search card")
        }

        enum Search {
            /// "Search GitHub users and repositories"
            static let placeholder   = NSLocalizedString("github_search.search.placeholder",   comment: "Placeholder text inside the search text field")
            /// "Users + repositories"
            static let captionTypes  = NSLocalizedString("github_search.search.caption_types", comment: "Caption describing supported search types")

            /// "Minimum %lld characters"
            static func captionMinimum(_ count: Int) -> String {
                String(format: NSLocalizedString("github_search.search.caption_minimum", comment: "Caption showing minimum required character count"), count)
            }
        }

        enum Loading {
            /// "Searching GitHub..."
            static let title    = NSLocalizedString("github_search.loading.title",    comment: "Title shown while fetching results")
            /// "Matching users and repositories are on the way."
            static let subtitle = NSLocalizedString("github_search.loading.subtitle", comment: "Subtitle shown while fetching results")
        }

        enum Idle {
            /// "Start typing"
            static let title = NSLocalizedString("github_search.idle.title", comment: "Title of the idle state before the user types")

            /// "Enter at least %lld characters to search GitHub."
            static func subtitle(_ count: Int) -> String {
                String(format: NSLocalizedString("github_search.idle.subtitle", comment: "Subtitle explaining the minimum character requirement"), count)
            }
        }

        enum Empty {
            /// "No results"
            static let title    = NSLocalizedString("github_search.empty.title",    comment: "Title of the empty-results state")
            /// "Try a different user or repository name."
            static let subtitle = NSLocalizedString("github_search.empty.subtitle", comment: "Subtitle of the empty-results state")
        }

        enum Error {
            /// "Search failed"
            static let title = NSLocalizedString("github_search.error.title", comment: "Title of the error state")
            /// "GitHub temporarily rejected the request. This usually means the search rate limit was reached. …"
            static let messageForbidden = NSLocalizedString("github_search.error.message_forbidden", comment: "Error message when GitHub returns 403 – rate limit hit or request blocked")
            /// "GitHub rejected the token. Check `GITHUB_TOKEN` and try again."
            static let messageUnauthorized = NSLocalizedString("github_search.error.message_unauthorized", comment: "Error message when GitHub returns 401 – token is invalid or missing")
            /// "Unable to load more results."
            static let messageNextPage = NSLocalizedString("github_search.error.message_next_page", comment: "Error message shown when loading the next page of results fails")
            /// "Unable to load results. Please try again."
            static let messageSearch = NSLocalizedString("github_search.error.message_search", comment: "Generic error message shown when the initial search request fails")
        }

        enum Result {
            /// "Repository"
            static let kindRepository = NSLocalizedString("github_search.result.kind_repository", comment: "Badge label for a repository result")
            /// "User"
            static let kindUser       = NSLocalizedString("github_search.result.kind_user",       comment: "Badge label for a user result")

            /// "Loaded %lld results"
            static func loadedCount(_ count: Int) -> String {
                String(format: NSLocalizedString("github_search.result.loaded_count", comment: "Small summary label above the results list showing how many items are currently loaded"), count)
            }
        }

        enum Pagination {
            /// "Retry loading more results"
            static let retry         = NSLocalizedString("github_search.pagination.retry",         comment: "Button label to retry loading the next page")
            /// "Loading more results..."
            static let loading       = NSLocalizedString("github_search.pagination.loading",       comment: "Text shown while loading the next page")
            /// "Keep scrolling for more"
            static let keepScrolling = NSLocalizedString("github_search.pagination.keep_scrolling", comment: "Hint shown when more results are available")
        }
    }
}

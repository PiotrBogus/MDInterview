# GitHub Search — iOS Demo App

An iOS app that lets you search GitHub repositories and users in real time, with debounced autocomplete, cursor-based pagination, and light/dark theme support.

## Requirements

- Xcode 16+
- iOS 26 simulator or device
- A GitHub personal access token (optional but recommended — without one the GitHub Search API rate-limits quickly)

## Setup

### 1. Clone and open

```bash
git clone <repo-url>
open Interview/Interview.xcodeproj
```

Xcode resolves the Swift Package dependencies automatically on first open.

### 2. GitHub token

The app reads the token at launch from the `GITHUB_TOKEN` environment variable, or you can enter it manually in the in-app onboarding screen. To pre-configure it for simulator runs:

1. In Xcode, open **Product → Scheme → Edit Scheme…**
2. Select **Run → Arguments → Environment Variables**
3. Add `GITHUB_TOKEN` with your personal access token as the value

Alternatively, skip token setup in the app to try the search with the unauthenticated rate limit (60 requests/hour).

### 3. Build and run

Select the **Interview** scheme, choose an iPhone simulator, and press **Run** (⌘R).

---

## Features

### Real-time GitHub search

- Searches users and repositories simultaneously via the GitHub Search API
- Debounce (300 ms by default) prevents requests while the user is still typing
- Minimum query length of 3 characters before any request fires
- Latest query always wins — in-flight requests for stale queries are cancelled

### Cursor-based pagination

- First page fetches up to 50 combined results (users + repositories)
- When the list is scrolled to the bottom, the next page is appended automatically
- Results from both endpoints are merged and sorted alphabetically across pages
- Overflow items are buffered so the combined page size stays consistent

### Token onboarding

- Shown on first launch if no token is configured
- Supports show/hide toggle for the token field
- Skippable — the app works without a token at reduced rate limits

### Appearance settings

- Three modes: **System** (follows device setting), **Light**, **Dark**
- Preference is persisted across launches

---

## Architecture

The app follows a unidirectional data-flow pattern. Each screen has a `ViewModel` that holds a `State` struct and accepts `Action` values via a single `send(_:)` method. Views are pure functions of state.

```
View  →  send(Action)  →  ViewModel  →  State (published)  →  View
                               ↕
                           Service / Network
```

Async work (network calls, debounce) runs in unstructured `Task`s owned by the ViewModel. Tasks are cancelled when a new query arrives or the ViewModel is deallocated.

### Module structure

```
Interview/
├── App/
│   ├── AppEngine.swift          # Dependency injection root
│   ├── AppLauncher.swift        # Setup state + colour scheme coordinator
│   └── EngineServices/          # ColorSchemeService, GitHubTokenStore
├── Features/
│   ├── GitHubAutocomplete/      # Search field, ViewModel, pagination, API service
│   ├── Search/                  # Root screen composing the autocomplete view
│   ├── Settings/                # Appearance picker
│   └── TokenSetup/              # First-launch token onboarding
└── Modules/                     # Local Swift packages
    ├── INetwork/                # HTTP client, OAuth2 interceptor, request deduplication
    ├── IDesignSystem/           # Colour palette, typography, spacing tokens, shared components
    └── IResources/              # Shared image assets
```

### Key types

| Type | Responsibility |
|---|---|
| `AppEngine` | Assembles and vends services; recreated after token setup completes |
| `GitHubSearchService` | Fetches users and repositories concurrently, merges and paginates results |
| `GitHubAutocompleteViewModel` | Debounce, cancellation, pagination state, error mapping |
| `ColorSchemeService` | Reads/writes color scheme preference to `UserDefaults` |
| `GitHubTokenStore` | Reads/writes the GitHub token to the keychain |
| `APIClient` (INetwork) | Type-safe HTTP client with interceptor chain |
| `OAuth2Interceptor` (INetwork) | Injects Bearer token; coordinates refresh on 401 |

---

## Testing

The project uses Swift Testing (`@Suite`, `@Test`, `#expect`) throughout.

```bash
# Run all tests
xcodebuild test \
  -scheme Interview \
  -destination 'platform=iOS Simulator,name=iPhone 17'
```

### Test suites

| Suite | What it covers |
|---|---|
| `GitHubAutocompleteTests` | Search logic: sorting, pagination math, debounce, cancellation, error mapping |
| `SearchViewModelTests` | Root screen state transitions |
| `TokenSetupViewModelTests` | Token validation and save/skip flows |
| `SettingsViewModelTests` | Colour scheme preference persistence |
| `ColorSchemeServiceTests` | `UserDefaults` read/write |
| `GitHubTokenStoreTests` | Keychain read/write |
| `GitHubAutocompleteViewSnapshotTests` | Snapshot tests for all autocomplete states (idle, loading, results, empty, error) × light/dark |
| `SettingsViewSnapshotTests` | Snapshot tests for all three colour-scheme options × light/dark |
| `TokenSetupViewSnapshotTests` | Snapshot tests for empty and pre-filled token field × light/dark |

Snapshot tests use [swift-snapshot-testing](https://github.com/pointfreeco/swift-snapshot-testing). Reference images live in `InterviewTests/__Snapshots__/`. Delete a snapshot file to re-record it.

### Testing approach for async ViewModels

ViewModel tests avoid `Task.sleep` for synchronisation. Instead:

- **Task awaiting** — `searchTask` and `paginationTask` are package-internal, so tests do `await viewModel.searchTask?.value` to block until the in-flight operation finishes.
- **Gate actors** — `DebounceGate` suspends the debounce sleep via a `CheckedContinuation`, giving tests precise control over when the debounce window ends.
- **Search signals** — `MockGitHubSearchService.waitUntilSearchCalled(query:)` blocks until the service has actually received a specific query, enabling deterministic in-flight cancellation tests.

---

## Dependencies

| Dependency | Source | Purpose |
|---|---|---|
| [swift-snapshot-testing](https://github.com/pointfreeco/swift-snapshot-testing) | Remote SPM | UI snapshot testing |
| INetwork | Local SPM (`Modules/INetwork`) | HTTP client, OAuth2, request deduplication |
| IDesignSystem | Local SPM (`Modules/IDesignSystem`) | Design tokens and shared UI components |
| IResources | Local SPM (`Modules/IResources`) | Shared image assets |

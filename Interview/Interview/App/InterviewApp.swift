import SwiftUI

@main
struct InterviewApp: App {
    @StateObject private var launcher = AppLauncher(engine: .live())

    var body: some Scene {
        WindowGroup {
            Group {
                if launcher.isSetupComplete {
                    SearchView(
                        searchService: launcher.engine.gitHubSearchService,
                        colorSchemeService: launcher.engine.colorSchemeService
                    )
                } else {
                    TokenSetupView(initialToken: launcher.engine.tokenStore.token) { token in
                        launcher.completeSetup(token: token)
                    }
                }
            }
            .animation(.easeInOut(duration: 0.4), value: launcher.isSetupComplete)
            .preferredColorScheme(launcher.colorSchemePreference.colorScheme)
        }
    }
}

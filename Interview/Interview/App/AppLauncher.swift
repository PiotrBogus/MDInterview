import Combine
import SwiftUI

@MainActor
final class AppLauncher: ObservableObject {
    @Published private(set) var isSetupComplete: Bool
    @Published private(set) var colorSchemePreference: ColorSchemePreference
    private(set) var engine: AppEngine

    private var cancellables = Set<AnyCancellable>()

    init(engine: AppEngine) {
        self.engine = engine
        self.isSetupComplete = false
        self.colorSchemePreference = engine.colorSchemeService.load()

        subscribeToColorScheme(engine.colorSchemeService)
    }

    func completeSetup(token: String?) {
        engine.tokenStore.completeSetup(token: token)
        engine = AppEngine.live(overrideToken: engine.tokenStore.token)
        subscribeToColorScheme(engine.colorSchemeService)
        isSetupComplete = true
    }

    private func subscribeToColorScheme(_ service: any ColorSchemeServiceProviding) {
        cancellables.removeAll()
        service.preferencePublisher
            .dropFirst()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] preference in
                self?.colorSchemePreference = preference
            }
            .store(in: &cancellables)
    }
}

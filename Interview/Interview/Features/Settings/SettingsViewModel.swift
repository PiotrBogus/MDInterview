import Combine

@MainActor
final class SettingsViewModel: ObservableObject {

    struct State: Equatable {
        var colorSchemePreference: ColorSchemePreference
    }

    enum Action {
        case colorSchemeChanged(ColorSchemePreference)
    }

    @Published private(set) var state: State

    private let colorSchemeService: any ColorSchemeServiceProviding

    init(colorSchemeService: any ColorSchemeServiceProviding) {
        self.colorSchemeService = colorSchemeService
        self.state = State(colorSchemePreference: colorSchemeService.load())
    }

    func send(_ action: Action) {
        switch action {
        case .colorSchemeChanged(let preference):
            state.colorSchemePreference = preference
            colorSchemeService.save(preference)
        }
    }
}

import Combine
import Testing
@testable import Interview

@Suite("SettingsViewModel")
@MainActor
struct SettingsViewModelTests {

    // MARK: - Initial state

    @Test
    func initialStateLoadsColorSchemeFromService() {
        let service = MockColorSchemeService(initial: .dark)

        let viewModel = SettingsViewModel(colorSchemeService: service)

        #expect(viewModel.state.colorSchemePreference == .dark)
    }

    @Test(arguments: ColorSchemePreference.allCases)
    func initialStateReflectsEachPreference(preference: ColorSchemePreference) {
        let service = MockColorSchemeService(initial: preference)

        let viewModel = SettingsViewModel(colorSchemeService: service)

        #expect(viewModel.state.colorSchemePreference == preference)
    }

    // MARK: - colorSchemeChanged action

    @Test
    func colorSchemeChangedUpdatesState() {
        let service = MockColorSchemeService(initial: .system)
        let viewModel = SettingsViewModel(colorSchemeService: service)

        viewModel.send(.colorSchemeChanged(.dark))

        #expect(viewModel.state.colorSchemePreference == .dark)
    }

    @Test
    func colorSchemeChangedPersistsToService() {
        let service = MockColorSchemeService(initial: .system)
        let viewModel = SettingsViewModel(colorSchemeService: service)

        viewModel.send(.colorSchemeChanged(.light))

        #expect(service.saved == .light)
    }

    @Test
    func colorSchemeChangedUpdatesBothStateAndServiceAtOnce() {
        let service = MockColorSchemeService(initial: .system)
        let viewModel = SettingsViewModel(colorSchemeService: service)

        viewModel.send(.colorSchemeChanged(.dark))

        #expect(viewModel.state.colorSchemePreference == .dark)
        #expect(service.saved == .dark)
    }

    @Test
    func subsequentChangesOverwritePreviousValue() {
        let service = MockColorSchemeService(initial: .system)
        let viewModel = SettingsViewModel(colorSchemeService: service)

        viewModel.send(.colorSchemeChanged(.dark))
        viewModel.send(.colorSchemeChanged(.light))

        #expect(viewModel.state.colorSchemePreference == .light)
        #expect(service.saved == .light)
    }

    @Test
    func sendingCurrentValueAgainIsIdempotent() {
        let service = MockColorSchemeService(initial: .dark)
        let viewModel = SettingsViewModel(colorSchemeService: service)

        viewModel.send(.colorSchemeChanged(.dark))

        #expect(viewModel.state.colorSchemePreference == .dark)
        #expect(service.saveCallCount == 1)
    }
}

// MARK: - Mock

private final class MockColorSchemeService: ColorSchemeServiceProviding, @unchecked Sendable {
    private let subject: CurrentValueSubject<ColorSchemePreference, Never>
    private(set) var saved: ColorSchemePreference?
    private(set) var saveCallCount = 0

    var preferencePublisher: AnyPublisher<ColorSchemePreference, Never> {
        subject.eraseToAnyPublisher()
    }

    init(initial: ColorSchemePreference = .system) {
        subject = CurrentValueSubject(initial)
    }

    func load() -> ColorSchemePreference { subject.value }

    func save(_ preference: ColorSchemePreference) {
        saved = preference
        saveCallCount += 1
        subject.send(preference)
    }
}

import Combine
import Foundation
import Testing
@testable import Interview

@Suite("ColorSchemeService", .serialized)
struct ColorSchemeServiceTests {
    private static let testSuiteName = "com.interview.tests.colorScheme"

    init() {
        UserDefaults.standard.removePersistentDomain(forName: Self.testSuiteName)
    }

    private func makeDefaults() -> UserDefaults {
        UserDefaults(suiteName: Self.testSuiteName)!
    }

    private func makeService() -> ColorSchemeService {
        ColorSchemeService(defaults: makeDefaults())
    }

    // MARK: - Initial load

    @Test
    func defaultsToSystemWhenNothingStored() {
        let service = makeService()

        #expect(service.load() == .system)
    }

    @Test(arguments: ColorSchemePreference.allCases)
    func loadsStoredPreferenceOnInit(preference: ColorSchemePreference) {
        let defaults = makeDefaults()
        defaults.set(preference.rawValue, forKey: ColorSchemeService.storageKey)

        let service = ColorSchemeService(defaults: defaults)

        #expect(service.load() == preference)
    }

    @Test
    func ignoresUnrecognizedStoredValue() {
        let defaults = makeDefaults()
        defaults.set("invalid_value", forKey: ColorSchemeService.storageKey)

        let service = ColorSchemeService(defaults: defaults)

        #expect(service.load() == .system)
    }

    // MARK: - save / load round-trip

    @Test
    func loadReturnsValueAfterSave() {
        let service = makeService()

        service.save(.dark)

        #expect(service.load() == .dark)
    }

    @Test
    func saveWritesRawValueToDefaults() {
        let defaults = makeDefaults()
        let service = ColorSchemeService(defaults: defaults)

        service.save(.light)

        #expect(defaults.string(forKey: ColorSchemeService.storageKey) == "light")
    }

    @Test
    func subsequentSavesOverwritePreviousValue() {
        let service = makeService()

        service.save(.dark)
        service.save(.light)

        #expect(service.load() == .light)
    }

    @Test
    func newInstancePicksUpPersistedValue() {
        let defaults = makeDefaults()
        ColorSchemeService(defaults: defaults).save(.dark)

        let second = ColorSchemeService(defaults: defaults)

        #expect(second.load() == .dark)
    }

    // MARK: - Publisher

    @Test
    func publisherEmitsCurrentValueOnSubscription() {
        let defaults = makeDefaults()
        defaults.set(ColorSchemePreference.light.rawValue, forKey: ColorSchemeService.storageKey)
        let service = ColorSchemeService(defaults: defaults)
        var received: [ColorSchemePreference] = []

        let cancellable = service.preferencePublisher.sink { received.append($0) }
        defer { cancellable.cancel() }

        #expect(received == [.light])
    }

    @Test
    func publisherEmitsEachSavedValue() {
        let service = makeService()
        var received: [ColorSchemePreference] = []

        let cancellable = service.preferencePublisher.sink { received.append($0) }
        defer { cancellable.cancel() }

        service.save(.dark)
        service.save(.light)

        #expect(received == [.system, .dark, .light])
    }

    @Test
    func cancelledSubscriberReceivesNoFurtherUpdates() {
        let service = makeService()
        var received: [ColorSchemePreference] = []
        let cancellable = service.preferencePublisher.sink { received.append($0) }

        cancellable.cancel()
        service.save(.dark)

        #expect(received == [.system])
    }
}

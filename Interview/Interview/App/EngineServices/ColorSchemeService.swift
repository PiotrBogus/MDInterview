import Combine
import Foundation

protocol ColorSchemeServiceProviding: Sendable {
    var preferencePublisher: AnyPublisher<ColorSchemePreference, Never> { get }
    func load() -> ColorSchemePreference
    func save(_ preference: ColorSchemePreference)
}

final class ColorSchemeService: ColorSchemeServiceProviding, @unchecked Sendable {
    static let storageKey = "app.colorScheme"

    private let defaults: UserDefaults
    private let subject: CurrentValueSubject<ColorSchemePreference, Never>

    var preferencePublisher: AnyPublisher<ColorSchemePreference, Never> {
        subject.eraseToAnyPublisher()
    }

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        let stored = defaults.string(forKey: Self.storageKey)
            .flatMap(ColorSchemePreference.init(rawValue:)) ?? .system
        self.subject = CurrentValueSubject(stored)
    }

    func load() -> ColorSchemePreference {
        subject.value
    }

    func save(_ preference: ColorSchemePreference) {
        defaults.set(preference.rawValue, forKey: Self.storageKey)
        subject.send(preference)
    }
}

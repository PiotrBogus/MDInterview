import Combine
import SnapshotTesting
import SwiftUI
import Testing
@testable import Interview

@Suite("SettingsView — Snapshots")
@MainActor
struct SettingsViewSnapshotTests {

    // MARK: - System (follows traits)

    @Test
    func systemSelected_light() {
        assertSnapshot(
            of: SettingsView(colorSchemeService: FixedColorSchemeService(.system)),
            as: .image(layout: .device(config: .iPhone13))
        )
    }

    @Test
    func systemSelected_dark() {
        assertSnapshot(
            of: SettingsView(colorSchemeService: FixedColorSchemeService(.system)),
            as: .image(layout: .device(config: .iPhone13), traits: .init(userInterfaceStyle: .dark))
        )
    }

    // MARK: - Light (forced regardless of traits)

    @Test
    func lightSelected_light() {
        assertSnapshot(
            of: SettingsView(colorSchemeService: FixedColorSchemeService(.light)),
            as: .image(layout: .device(config: .iPhone13))
        )
    }

    @Test
    func lightSelected_dark() {
        assertSnapshot(
            of: SettingsView(colorSchemeService: FixedColorSchemeService(.light)),
            as: .image(layout: .device(config: .iPhone13), traits: .init(userInterfaceStyle: .dark))
        )
    }

    // MARK: - Dark (forced regardless of traits)

    @Test
    func darkSelected_light() {
        assertSnapshot(
            of: SettingsView(colorSchemeService: FixedColorSchemeService(.dark)),
            as: .image(layout: .device(config: .iPhone13), traits: .init(userInterfaceStyle: .light))
        )
    }

    @Test
    func darkSelected_dark() {
        assertSnapshot(
            of: SettingsView(colorSchemeService: FixedColorSchemeService(.dark)),
            as: .image(layout: .device(config: .iPhone13), traits: .init(userInterfaceStyle: .dark))
        )
    }
}

// MARK: - Helpers

private struct FixedColorSchemeService: ColorSchemeServiceProviding {
    private let preference: ColorSchemePreference

    var preferencePublisher: AnyPublisher<ColorSchemePreference, Never> {
        Just(preference).eraseToAnyPublisher()
    }

    init(_ preference: ColorSchemePreference) {
        self.preference = preference
    }

    func load() -> ColorSchemePreference { preference }
    func save(_ preference: ColorSchemePreference) {}
}

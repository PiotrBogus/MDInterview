import SnapshotTesting
import SwiftUI
import Testing
@testable import Interview

@Suite("TokenSetupView — Snapshots")
@MainActor
struct TokenSetupViewSnapshotTests {

    // MARK: - Empty

    @Test
    func empty_light() {
        assertSnapshot(
            of: TokenSetupView { _ in },
            as: .image(layout: .device(config: .iPhone13))
        )
    }

    @Test
    func empty_dark() {
        assertSnapshot(
            of: TokenSetupView { _ in },
            as: .image(layout: .device(config: .iPhone13), traits: .init(userInterfaceStyle: .dark))
        )
    }

    // MARK: - With token pre-filled

    @Test
    func withToken_light() {
        assertSnapshot(
            of: TokenSetupView(initialToken: "ghp_abc123xyz") { _ in },
            as: .image(layout: .device(config: .iPhone13))
        )
    }

    @Test
    func withToken_dark() {
        assertSnapshot(
            of: TokenSetupView(initialToken: "ghp_abc123xyz") { _ in },
            as: .image(layout: .device(config: .iPhone13), traits: .init(userInterfaceStyle: .dark))
        )
    }
}

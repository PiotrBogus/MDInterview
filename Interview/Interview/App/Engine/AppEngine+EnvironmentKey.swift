import SwiftUI

private struct AppEngineKey: EnvironmentKey {
    static let defaultValue = AppEngine.live()
}

extension EnvironmentValues {
    var appEngine: AppEngine {
        get { self[AppEngineKey.self] }
        set { self[AppEngineKey.self] = newValue }
    }
}

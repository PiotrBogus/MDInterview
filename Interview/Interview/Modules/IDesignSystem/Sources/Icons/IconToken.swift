import SwiftUI

public enum IconToken: String, Sendable {
    case search = "magnifyingglass"
    case searchPrompt = "sparkle.magnifyingglass"
    case repository = "folder.fill"
    case user = "person.crop.circle.fill"
    case empty = "tray.fill"
    case error = "exclamationmark.triangle.fill"
    case selected = "checkmark.seal.fill"
    case external = "arrow.up.right"
    case chevron = "chevron.right"
    case clear = "xmark.circle.fill"
    case pulse = "waveform.path.ecg"
    case settings = "gearshape.fill"
    case moon = "moon.fill"
    case sun = "sun.max.fill"
    case key = "key.horizontal.fill"
    case eye = "eye"
    case eyeSlash = "eye.slash"

    public var systemName: String {
        rawValue
    }
}

public extension Image {
    init(icon token: IconToken) {
        self.init(systemName: token.systemName)
    }
}

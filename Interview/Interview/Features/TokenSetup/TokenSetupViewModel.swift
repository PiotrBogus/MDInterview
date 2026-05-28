import Combine
import Foundation

@MainActor
final class TokenSetupViewModel: ObservableObject {
    @Published var tokenInput = ""
    @Published var isTokenVisible = false

    private let onComplete: (String?) -> Void

    init(initialToken: String? = nil, onComplete: @escaping (String?) -> Void) {
        self.tokenInput = initialToken ?? ""
        self.onComplete = onComplete
    }

    var canSave: Bool {
        !tokenInput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    func save() {
        onComplete(tokenInput.trimmingCharacters(in: .whitespacesAndNewlines))
    }

    func skip() {
        onComplete(nil)
    }
}

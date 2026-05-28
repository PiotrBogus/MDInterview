import Foundation
import Security

public actor KeychainOAuth2TokenStore: OAuth2TokenStore {
    private let service: String
    private let account: String
    private let accessibility: CFString
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    public init(
        service: String,
        account: String = "oauth2-token",
        accessibility: CFString = kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly
    ) {
        self.service = service
        self.account = account
        self.accessibility = accessibility
    }

    public func token() async -> OAuth2Token? {
        do {
            return try readToken()
        } catch {
            assertionFailure("Failed to read OAuth2 token from Keychain: \(error)")
            return nil
        }
    }

    public func save(token: OAuth2Token?) async {
        do {
            guard let token else {
                try deleteToken()
                return
            }

            try upsertToken(token)
        } catch {
            assertionFailure("Failed to save OAuth2 token to Keychain: \(error)")
        }
    }

    private func readToken() throws -> OAuth2Token? {
        var query = baseQuery
        query[kSecReturnData as String] = true
        query[kSecMatchLimit as String] = kSecMatchLimitOne

        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)

        switch status {
        case errSecSuccess:
            guard let data = item as? Data else {
                throw KeychainOAuth2TokenStoreError.invalidData
            }

            return try decoder.decode(OAuth2Token.self, from: data)
        case errSecItemNotFound:
            return nil
        default:
            throw KeychainOAuth2TokenStoreError.unhandledStatus(status)
        }
    }

    private func upsertToken(_ token: OAuth2Token) throws {
        let data = try encoder.encode(token)

        let attributes: [String: Any] = [
            kSecValueData as String: data,
            kSecAttrAccessible as String: accessibility
        ]

        let updateStatus = SecItemUpdate(baseQuery as CFDictionary, attributes as CFDictionary)

        if updateStatus == errSecItemNotFound {
            var addQuery = baseQuery
            attributes.forEach { addQuery[$0.key] = $0.value }

            let addStatus = SecItemAdd(addQuery as CFDictionary, nil)
            guard addStatus == errSecSuccess else {
                throw KeychainOAuth2TokenStoreError.unhandledStatus(addStatus)
            }

            return
        }

        guard updateStatus == errSecSuccess else {
            throw KeychainOAuth2TokenStoreError.unhandledStatus(updateStatus)
        }
    }

    private func deleteToken() throws {
        let status = SecItemDelete(baseQuery as CFDictionary)
        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw KeychainOAuth2TokenStoreError.unhandledStatus(status)
        }
    }

    private var baseQuery: [String: Any] {
        [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account
        ]
    }
}

private enum KeychainOAuth2TokenStoreError: LocalizedError {
    case invalidData
    case unhandledStatus(OSStatus)

    var errorDescription: String? {
        switch self {
        case .invalidData:
            return "Keychain returned unexpected data for OAuth2Token."
        case let .unhandledStatus(status):
            if let message = SecCopyErrorMessageString(status, nil) as String? {
                return message
            }

            return "Keychain error with status \(status)."
        }
    }
}

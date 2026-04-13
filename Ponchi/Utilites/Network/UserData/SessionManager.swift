//
//  SessionManager.swift
//  Ponchi
//
//  Created by mary romanova on 26.01.2026.
//

import Foundation
import SwiftUI

enum SessionManagerError: Error {
    case faildToSAveToken
}

@MainActor
final class SessionManager: ObservableObject {
    @Published private(set) var isLoggedIn = false
    private(set) var token: String?

    private let keychain: KeychainService
    private let tokenKey: String

    init(
        keychain: KeychainService,
        tokenKey: String = KeychainKey.authToken
    ) {
        self.keychain = keychain
        self.tokenKey = tokenKey
        self.token = keychain.read(tokenKey)
        self.isLoggedIn = token != nil
    }

    func save(token: String) throws {
        guard keychain.save(token, for: tokenKey) else { throw SessionManagerError.faildToSAveToken }
        self.token = token
        self.isLoggedIn = true
    }

    func clear() {
        keychain.delete(tokenKey)
        token = nil
        isLoggedIn = false
    }
}

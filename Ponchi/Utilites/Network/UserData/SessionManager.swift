//
//  SessionManager.swift
//  Ponchi
//
//  Created by mary romanova on 26.01.2026.
//

import Foundation
import SwiftUI
import Security

final class SessionManager: ObservableObject {
    static let shared = SessionManager()
    
    @Published var isLoggedIn = false
    private var sessionKey = "userSessionID"
    
    private init() {
        checkSession()
    }
    
    func checkSession() {
        if let existingToken = KeychainService.shared.read(sessionKey) {
            print("сессия уже есть \(existingToken)")
            isLoggedIn = true
        } else {
            let newToken = UUID().uuidString
            let success = KeychainService.shared.save(newToken, for: sessionKey)
            if success {
                print("создана новая сессия \(newToken)")
            } else {
                print("токен не удалось сохранить")
            }
            isLoggedIn = true
        }
        
        func logout() {
            KeychainService.shared.delete(sessionKey)
            isLoggedIn = false
        }
    }
}

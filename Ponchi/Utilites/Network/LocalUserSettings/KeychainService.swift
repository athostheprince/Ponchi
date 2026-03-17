//
//  KeychainService .swift
//  Ponchi
//
//  Created by mary romanova on 26.01.2026.
//

import Security
import Foundation

final class KeychainService {
    static let shared = KeychainService()
    
    private init() {}
    
    func save(_ value: String, for key: String) -> Bool {
        guard let data = value.data(using: .utf8) else { return false }
        
        let query: [String: Any] = [
            kSecClass as String : kSecClassGenericPassword,
            kSecAttrAccount as String : key,
            kSecValueData as String  : data
        ]
        
        SecItemDelete(query as CFDictionary)
        let status = SecItemAdd(query as CFDictionary, nil)
        return status == errSecSuccess
    }
    
    func read(_ key: String) -> String? {
        let query: [String: Any] = [
            kSecClass as String : kSecClassGenericPassword,
            kSecAttrAccount as String : key,
            kSecValueData as String  : true,
            kSecMatchLimit as String : kSecMatchLimitOne
            ]
        
        var dataTypeRef: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &dataTypeRef)
        
        guard status == errSecSuccess,
              let data = dataTypeRef as? Data,
              let value = String(data: data, encoding: .utf8)
        else { return nil }
        
        return value
    }
    
    func delete(_ key: String) {
        let query: [String: Any] = [
            kSecClass as String : kSecClassGenericPassword,
            kSecAttrAccount as String : key
        ]
        SecItemDelete(query as CFDictionary)
    }
}

//
//  AuthResponseModels.swift
//  Ponchi
//
//  Created by mary romanova on 25.03.2026.
//

import Foundation

struct LoginRequest: Encodable {
    let phone: String
    let password: String
}

struct RequestCodeRequest: Encodable {
    let phone: String
    let purpose: String
}

struct VerifyCodeRequest: Encodable {
    let phone: String
    let code: String
    let name: String
    let password: String
}

struct ResetPasswordRequest: Encodable {
    let phone: String
    let code: String
    let newPassword: String 
}

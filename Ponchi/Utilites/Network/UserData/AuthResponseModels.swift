//
//  AuthModels.swift
//  Ponchi
//
//  Created by mary romanova on 25.03.2026.
//

import Foundation

struct APIUser: Decodable {
    let id: String
    let phone: String
    let name: String
    let bonuses: Int
    let avatar: String?
    let createdAt: String
}

struct AuthSuccessResponse: Decodable {
    let accessToken: String
    let user: APIUser
}

struct RequestCodeResponse: Decodable {
    let ok: Bool
    let retryAfter: Int
}

struct OKResponse: Decodable {
    let ok: Bool
}

struct ErrorResponse: Decodable {
    let error: String
}

extension User {
    init(apiUser: APIUser) {
        self.id = apiUser.id
        self.name = apiUser.name
        self.number = apiUser.phone
        self.bonuses = apiUser.bonuses
        self.avatar = apiUser.avatar
    }
}

//
//  AuthService.swift
//  Ponchi
//
//  Created by mary romanova on 05.04.2026.
//

import Foundation

struct AuthService {
    private let network: NetworkService
    private let baseURL: URL

    init(network: NetworkService, baseURL: URL) {
        self.network = network
        self.baseURL = baseURL
    }

    func login(phone: String, password: String) async throws -> AuthSuccessResponse {
            try await network.request(
                baseURL.appendingPathComponent("auth/login"),
                method: "POST",
                body: LoginRequest(phone: phone, password: password)
            )
        }

    func requestCode(phone: String, purpose: String) async throws -> RequestCodeResponse {
        let request = RequestCodeRequest(phone: phone, purpose: purpose)

        return try await network.request(
            baseURL.appendingPathComponent("auth/request_code"),
            method: "POST",
            body: request
        )
    }

    func verifyCode(phone: String, code: String, name: String, password: String) async throws -> AuthSuccessResponse {
        let request = VerifyCodeRequest(phone: phone, code: code, name: name, password: password)

        return try await network.request(
            baseURL.appendingPathComponent("auth/verify_code"),
            method: "POST",
            body: request
        )
    }

    func resetPassword(phone: String, code: String, newPassword: String) async throws -> OKResponse {
        let request = ResetPasswordRequest(phone: phone, code: code, newPassword: newPassword)

        return try await network.request(
            baseURL.appendingPathComponent("auth/reset_password"),
            method: "POST",
            body: request
        )
    }

    func me(token: String) async throws -> APIUser {
            try await network.request(
                baseURL.appendingPathComponent("me"),
                method: "GET",
                headers: ["Authorization": "Bearer \(token)"]
            )
        }
}

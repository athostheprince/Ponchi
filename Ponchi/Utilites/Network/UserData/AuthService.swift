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
    private let backend: AppConfig.AuthBackend

    init(network: NetworkService, baseURL: URL, backend: AppConfig.AuthBackend = .yandex) {
        self.network = network
        self.baseURL = baseURL
        self.backend = backend
    }

    func login(phone: String, password: String) async throws -> AuthSuccessResponse {
            try await network.request(
                endpointURL(yandexPath: "auth/login", supabaseFunction: "auth-login"),
                method: "POST",
                body: LoginRequest(phone: phone, password: password)
            )
        }

    func requestCode(phone: String, purpose: AuthCodePurpose) async throws -> RequestCodeResponse {
        let request = RequestCodeRequest(phone: phone, purpose: purpose)

        return try await network.request(
            endpointURL(yandexPath: "auth/request_code", supabaseFunction: "auth-request-code"),
            method: "POST",
            body: request
        )
    }

    func verifyCode(phone: String, code: String, name: String, password: String) async throws -> AuthSuccessResponse {
        let request = VerifyCodeRequest(phone: phone, code: code, name: name, password: password)

        return try await network.request(
            endpointURL(yandexPath: "auth/verify_code", supabaseFunction: "auth-verify-code"),
            method: "POST",
            body: request
        )
    }

    func resetPassword(phone: String, code: String, newPassword: String) async throws -> OKResponse {
        let request = ResetPasswordRequest(phone: phone, code: code, newPassword: newPassword)

        return try await network.request(
            endpointURL(yandexPath: "auth/reset_password", supabaseFunction: "auth-reset-password"),
            method: "POST",
            body: request
        )
    }

    func me(token: String) async throws -> APIUser {
            try await network.request(
                endpointURL(yandexPath: "me", supabaseFunction: "auth-me"),
                method: "GET",
                headers: ["Authorization": "Bearer \(token)"]
            )
        }

    private func endpointURL(yandexPath: String, supabaseFunction: String) -> URL {
        switch backend {
        case .yandex:
            return baseURL.appendingPathComponent(yandexPath)
        case .supabase:
            return baseURL.appendingPathComponent(supabaseFunction)
        }
    }
}

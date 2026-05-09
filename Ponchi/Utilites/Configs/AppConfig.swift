//
//  AppConfig.swift
//  Ponchi
//
//  Created by mary romanova on 13.04.2026.
//

import Foundation

enum AppConfig {
    enum AuthBackend: String {
        case yandex
        case supabase

        static func parse(_ rawValue: String) -> AuthBackend {
            AuthBackend(rawValue: rawValue.lowercased()) ?? .yandex
        }
    }

    static var apiBaseURL: URL {
        guard
            let raw = Bundle.main.object(forInfoDictionaryKey: "PonchiAPIBaseURL") as? String,
            let url = URL(string: raw)
        else {
            fatalError("PonchiAPIBaseURL is missing or invalid")
        }
        return url
    }

    static var authBackend: AuthBackend {
        guard let raw = Bundle.main.object(forInfoDictionaryKey: "PonchiAuthBackend") as? String else {
            return .yandex
        }

        return AuthBackend.parse(raw)
    }

    static var menuURL: URL {
        guard
            let raw = Bundle.main.object(forInfoDictionaryKey: "PonchiMenuURL") as? String,
            let url = URL(string: raw)
        else {
            fatalError("PonchiMenuURL is missing or invalid")
        }
        return url
    }

    static var yandexMapsAPIKey: String {
        guard let key = Bundle.main.object(forInfoDictionaryKey: "YandexMapsAPIKey") as? String,
              !key.isEmpty
        else {
            fatalError("YandexMapsAPIKey is missing")
        }
        return key
    }
}

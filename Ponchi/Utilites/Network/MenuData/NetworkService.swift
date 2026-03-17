//
//  NetworkService.swift
//  Ponchi
//
//  Created by mary romanova on 08.02.2026.
//

import Foundation

final class NetworkService {
    static let shared = NetworkService()

    private let session: URLSession

    init(session: URLSession = {
        let config = URLSessionConfiguration.ephemeral
        config.requestCachePolicy = .reloadIgnoringLocalCacheData
        config.urlCache = nil
        config.waitsForConnectivity = false
        config.timeoutIntervalForRequest = 10
        return URLSession(configuration: config)
    }()) {
        self.session = session
    }

    func fetch<T: Decodable>(_ url: URL) async throws -> T {
        var request = URLRequest(url: url)
        request.cachePolicy = .reloadIgnoringLocalCacheData
        request.timeoutInterval = 10
        request.setValue("no-cache", forHTTPHeaderField: "Cache-Control")
        request.setValue("no-cache", forHTTPHeaderField: "Pragma")

        let (data, response) = try await session.data(for: request)

        guard let http = response as? HTTPURLResponse,
              200..<300 ~= http.statusCode else {
            throw URLError(.badServerResponse)
        }
        return try JSONDecoder().decode(T.self, from: data)
    }
}

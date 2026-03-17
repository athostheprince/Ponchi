//
//  MenuRemoteDataSource.swift
//  Ponchi
//
//  Created by mary romanova on 11.03.2026.
//

import Foundation

final class MenuRemoteDataSource {
    private let menuURL: URL
    private let network: NetworkService

    init(menuURL: URL, network: NetworkService = .shared) {
        self.menuURL = menuURL
        self.network = network
    }

    func fetchMenu() async throws -> [Ponchi] {
        try await network.fetch(menuURL)
    }
}

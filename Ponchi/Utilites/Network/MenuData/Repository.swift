//
//  Repository.swift
//  Ponchi
//
//  Created by mary romanova on 11.03.2026.
//

import Foundation

protocol MenuRepository {
    func loadMenu() async throws -> MenuResult
}

final class DefaultMenuRepository: MenuRepository {
    private let remote: MenuRemoteDataSource
    private let local: MenuLocalDataSource

    init(remote: MenuRemoteDataSource, local: MenuLocalDataSource) {
        self.remote = remote
        self.local = local
    }

    func loadMenu() async throws -> MenuResult {
        do {
            let items = try await remote.fetchMenu()
            return MenuResult(items: items, source: .remote, message: nil)
        } catch {
            let items = try local.loadMenu()
            let message = "не удалалось обновить меню, проверьте ваше подключение к сети"
            return MenuResult(items: items, source: .local, message: message)
        }
    }
}

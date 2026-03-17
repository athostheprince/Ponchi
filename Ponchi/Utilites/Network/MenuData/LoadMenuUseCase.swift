//
//  LoadMenuUseCase.swift
//  Ponchi
//
//  Created by mary romanova on 11.03.2026.
//

import Foundation

final class LoadMenuUseCase {
    private let repo: MenuRepository

    init(repo: MenuRepository) {
        self.repo = repo
    }

    func execute() async throws -> MenuResult {
        try await repo.loadMenu()
    }
}

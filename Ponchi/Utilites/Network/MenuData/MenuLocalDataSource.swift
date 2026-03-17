//
//  MenuLocalDataSource.swift
//  Ponchi
//
//  Created by mary romanova on 11.03.2026.
//

import Foundation

final class MenuLocalDataSource {
    private let local: LocalMenuService

    init(local: LocalMenuService = .shared) {
        self.local = local
    }
    func loadMenu() throws -> [Ponchi] {
        try local.loadMenu()
    }
}

//
//  LocalMenuService.swift
//  Ponchi
//
//  Created by mary romanova on 27.02.2026.
//

import Foundation

enum LocalMenuError: Error {
    case fileNotFound
}

final class LocalMenuService {
    static let shared = LocalMenuService()
    private init() {}

    func loadMenu() throws -> [Ponchi] {
        guard let url = Bundle.main.url(forResource: "Ponchi", withExtension: "json") else {
            throw LocalMenuError.fileNotFound
        }

        let data = try Data(contentsOf: url)
        return try JSONDecoder().decode([Ponchi].self, from: data)
    }
}

//
//  MenuResult.swift
//  Ponchi
//
//  Created by mary romanova on 11.03.2026.
//

import Foundation

enum MenuSource {
    case remote
    case local
}

struct MenuResult {
    let items: [Ponchi]
    let source: MenuSource
    let message: String?
}

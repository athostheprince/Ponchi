//
//  CartItem.swift
//  Ponchi
//
//  Created by mary romanova on 13.05.2026.
//

import Foundation
import SwiftUI

struct CartItem: Identifiable, Codable, Equatable {
    let productId: String
    let name: String
    let size: Size?
    let toppings: [ToppingOption]
    let comment: String
    let unitPrice: Int
    var quantity: Int

    var id: String {
        [
            productId,
            name,
            size?.rawValue ?? "no-size",
            toppings.map(\.id).sorted().joined(separator: ","),
            comment.trimmingCharacters(in: .whitespacesAndNewlines)
        ].joined(separator: "|")
    }

    var totalPrice: Int {
        let toppingsTotal = toppings.reduce(0) { $0 + $1.price }
        return (unitPrice + toppingsTotal) * quantity
    }
}

extension CartItem {
    init(ponchi: Ponchi, comment: String, quantity: Int = 1) {
        self.productId = ponchi.id
        self.name = ponchi.displayName
        self.size = ponchi.size
        self.toppings = ponchi.selectedToppings
        self.comment = comment.trimmingCharacters(in: .whitespacesAndNewlines)
        self.unitPrice = ponchi.basePrice
        self.quantity = quantity
    }
}

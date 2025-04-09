//
//  Order .swift
//  Ponchi
//
//  Created by mary romanova on 19.01.2025.
//

import Foundation
import SwiftUI

final class Cart: ObservableObject {
    
    @Published var items: [Ponchi] = []
    
    var total: Int {
        items.reduce(0) {
            $0 + $1.totalPrice 
        }
    }
    
    func deleteItems(_ item: Ponchi) {
        withAnimation {
            items.removeAll { $0.id == item.id }
        }
    }
    
    func addItem(_ ponchi: Ponchi) {
        if let index = items.firstIndex(where: { $0.id == ponchi.id }) {
            items[index].quantity += ponchi.quantity
        } else {
            items.append(ponchi)
        }
    }
    
    func removeItem(_ ponchi: Ponchi) {
        if let index = items.firstIndex(where: { $0.id == ponchi.id }) {
            if items[index].quantity > 1 {
                items[index].quantity -= 1
            } else {
                items.remove(at: index)
            }
        }
    }
    
    func clearCart() {
        items.removeAll()
    }
}

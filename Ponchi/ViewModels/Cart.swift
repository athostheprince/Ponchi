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
    @Published var animatedPrice: [Int] = []
    
    var total: Int {
        items.reduce(0) {
            $0 + $1.totalPrice 
        }
    }
    
    func totalPrice(for ponchi: Ponchi) -> Int {
        if let index = items.firstIndex(where: { $0.id == ponchi.id }) {
            let item = items[index]
            return item.totalPrice // quantity уже учтена внутри
        }
        return ponchi.totalPrice
    }

    func addUpsell(_ ponchi: Ponchi) {
        var item = ponchi
        item.quantity = 1
        addItem(item)
    }
    
    func deleteItems(_ item: Ponchi) {
        withAnimation {
            items.removeAll { $0.id == item.id }
        }
    }
    
    func addItem(_ ponchi: Ponchi) {
        if let index = items.firstIndex(where: { $0.id == ponchi.id }) {
            items[index].quantity += 1
        } else {
            items.append(ponchi)
        }
    }
    
    func removeItem(_ ponchi: Ponchi) {
        if let index = items.firstIndex(where: { $0.id == ponchi.id }) {
            if items[index].quantity > 1 {
                items[index].quantity -= 1
               items = items
            } else {
                items.remove(at: index)
            }
        }
    }
    
    func clearCart() {
        items.removeAll()
    }
    
    func getDigits(from number: Int) -> [Int] {
            return String(number).compactMap { $0.wholeNumberValue }
        }
        
    func animatePriceChange(to newValue: Int) {
        let newDigits = getDigits(from: newValue)
        let oldDigits = animatedPrice
        animatedPrice = oldDigits.enumerated().map { index, _ in
            index < newDigits.count ? newDigits[index] : 0
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                self.animatedPrice = newDigits
            }
        }
    }
}

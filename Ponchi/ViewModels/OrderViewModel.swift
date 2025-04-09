//
//  OrderViewModel.swift
//  Ponchi
//
//  Created by mary romanova on 02.02.2025.
//

import Foundation
import SwiftUI

final class OrderViewModel: ObservableObject {
    
    @Published var activeOrders: [Order] = []
    @Published var completedOrders: [Order] = []
    @Published var currentOrder = Order()
    
    func placeOrder(from cart: Cart) {
        guard !cart.items.isEmpty else { return }
        
        let newOrder = Order(items: cart.items)
        activeOrders.append(newOrder)
        cart.clearCart()
    }
    
    func completeOrder(with id: UUID) {
        if let index = activeOrders.firstIndex(where: { $0.id == id }) {
            var order = activeOrders.remove(at: index)
            order.status = .completed
            completedOrders.append(order)
        }
    }
    
}

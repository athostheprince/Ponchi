//
//  Order.swift
//  Ponchi
//
//  Created by mary romanova on 02.02.2025.
//

import Foundation
import SwiftUI

struct Order: Identifiable, Codable {
    var id = UUID()
    var items: [Ponchi] = []
    var totalPrice: Int {
        items.reduce(0) { $0 + $1.totalPrice }
    }
    var status: OrderStatus = .pending
    var date: Date = Date()
    
    enum OrderStatus: String, Codable {
        case pending = "В ожидании"
        case preparing = "Готовится"
        case completed = "Завершён"
        case cancelled = "Отменён"
    }
}

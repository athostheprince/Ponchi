//
//  PromoManager.swift
//  Ponchi
//
//  Created by mary romanova on 28.10.2025.
//

import Foundation
import SwiftUI

final class PromoManager: ObservableObject {
    @Published var currentPromos: [PromoItem] = []
    @Published var selectedPromo: PromoItem?
    
    init(for ponchiCategory: Category) {
        switch ponchiCategory {
        case .food: loadPromos(for: .food)
        case .coffee: loadPromos(for: .coffee)
        default: loadPromos(for: .coffee)
        }
    }
    
    func loadPromos(for category: Category) {
        switch category {
        case .coffee: currentPromos = []
        case .food: currentPromos = []
        default: currentPromos = []
        }
    }
}

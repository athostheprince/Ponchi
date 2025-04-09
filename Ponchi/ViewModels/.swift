//
//  PonchiViewModel.swift
//  Ponchi
//
//  Created by mary romanova on 27.11.2024.
//

import Foundation
import SwiftUI

class PonchiViewModel: ObservableObject {
    
    @Published var selectedPonchi: Ponchi?
    @Published var ponchis: [Ponchi] = MockPonchiData.all
    @Published var isShowingDetails = false
    @Published var selectedTab = 0
    @Published var selectedSegment = 0
    @Published var columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    @Published var newCategories: [Category] = Category.allCases
    @Published var selectedCategory: Category? = Category.allCases.first
    
    func selectCategory(_ category: Category) {
        selectedCategory = category
    }
    
    func categoryVisible(_ category: Category) {
        if selectedCategory != category {
            selectedCategory = category
        }
    }
    
    var categories: [String] {
        let uniqueCategories = Set(ponchis.map {
            $0.category.rawValue
        })
        return Array(uniqueCategories).sorted()
    }
    
    func getProducts(for category: String) -> [Ponchi] {
        ponchis.filter {
            $0.category.rawValue == category
        }
    }
    
    func selectedTab(_ index: Int) {
        selectedTab = index
    }
    
    func getCategory() -> [String] {
        MockPonchiData.all.map { $0.category.rawValue }.sorted()
    }
    
    func updateVisibleCategory(from values: [String: CGFloat]) {
        if let visibleCategory = values.min(by: { abs($0.value) < abs($1.value) })?.key,
           let visibleCategory = Category(rawValue: visibleCategory) {
            DispatchQueue.main.async {
                self.selectedCategory = visibleCategory
            }
        }
    }
}




//
//  PonchiViewModel.swift
//  Ponchi
//
//  Created by mary romanova on 15.12.2024.
//

import Foundation
import SwiftUI


class PonchiViewModel: ObservableObject {
    @Published var ponchis: [Ponchi] = MockPonchiData.all
    @Published var isShowingDetails = false
    @Published var selectedTab = 0
    @Published var selectedSegment = 0
    @Published var columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    @Published var categories: [Category] = Category.allCases
    @Published var selectedCategory: Category? = Category.allCases.first
    @Published var selectedIndex = 0
    @Published var selectedSizeIndex = 1
    @Published var ponchi: Ponchi?
    @Published var sizes: [Size] = Size.allCases
    @Published var pickerOptions: [Size] = Size.allCases
    @Published var selectedSize: Size? = .medium
    
    @Published var animatedPrice: [Int] = []
    
    @Published var availableToppings: [Topping]?
    @Published var showCategories = false
    @Published var selectedToppingCategory: ToppingCategory?
    @Published var selectedOption: String?
    @Published var isSelected = false 
    
    @Published var totalPrice: Int = 0
    
    @Published var selectedPonchi: Ponchi? {
        didSet {
            if selectedPonchi != nil {
                if let ponchi = selectedPonchi {
                    availableToppings = ponchi.availableToppings
                    selectedSize = ponchi.size ?? .medium
                    calculateTotalPrice()
                }
            }
        }
    }
    
    @Published var isShownCups = false
    @Published var searchTerm = ""
    @Published var isLiked = false

    @Published var selectedToppings: [ToppingOption] = []
    
    @Published var isPresented = true
    
    func selectSize(_ size: Size) {
        guard var currentPonchi = selectedPonchi else { return }
        currentPonchi.size = size
        selectedPonchi = currentPonchi
        selectedSize = size
        calculateTotalPrice()
    }
    
    func toggleToppingSelection(for option: ToppingOption, in category: Topping) {
        guard var availableToppings = availableToppings, var currentPonchi = selectedPonchi else { return }
        
        // Находим категорию
        if let categoryIndex = availableToppings.firstIndex(where: { $0.id == category.id }) {
            // Сбрасываем все выборы в этой категории
            for i in 0..<availableToppings[categoryIndex].options.count {
                availableToppings[categoryIndex].options[i].isSelected = false
            }
            
            // Выбираем новый вариант
            if let optionIndex = availableToppings[categoryIndex].options.firstIndex(where: { $0.id == option.id }) {
                availableToppings[categoryIndex].options[optionIndex].isSelected = true
            }
            
            // Обновляем пончи с новыми топпингами
            currentPonchi.availableToppings = availableToppings
            self.selectedPonchi = currentPonchi
            self.availableToppings = availableToppings
            
            // Немедленный пересчет цены
            calculateTotalPrice()
        }
    }
    
    
    var ml: String {
        
        switch selectedSize {
        case .small:
            return "200 мл"
        case .medium:
            return "300 мл"
        case .large:
            return "400 мл"
        default: break
        }
        return ""
    }
    
    var filteredProducts: [Ponchi] {
        guard !searchTerm.isEmpty else { return ponchis }
        return ponchis.filter { $0.name.localizedCaseInsensitiveContains(searchTerm) }
    }
    
    var availableSizes: [Size] {
        if let selectedPonchi = selectedPonchi, let fixedSizes = selectedPonchi.fixedSizes {
            return fixedSizes.map { $0.volume }
        }
        return Size.allCases.filter { $0 != .noSize }
    }
    
    
//    func selectSize(_ size: Size) {
//        guard selectedPonchi != nil else { return }
//        selectedPonchi?.size = size
//        calculateTotalPrice()
//    }
    
    func calculateTotalPrice() {
        guard let currentPonchi = selectedPonchi else { return }
        
        // Цена размера
        let sizePrice = currentPonchi.fixedSizes?.first { $0.volume == currentPonchi.size }?.price ?? currentPonchi.basePrice
        
        // Цена топпингов
        let toppingsPrice = currentPonchi.selectedToppings.reduce(0) { $0 + $1.price }
        
        // Итоговая цена с учетом количества
        let total = (sizePrice + toppingsPrice) * currentPonchi.quantity
        
        // Обновление с анимацией
        DispatchQueue.main.async {
            withAnimation {
                self.totalPrice = total
                self.animatePriceChange(to: total)
            }
        }
    }

    
    var newCategories: [Category] {
        return Category.allCases
    }
        
    func selectCategory(_ category: Category) {
        selectedCategory = category
    }

    func categoryVisible(_ category: Category) {
        if selectedCategory != category {
            selectedCategory = category
        }
    }
    
    func updateVisibleCategory(values: [Category: CGFloat]) {
        if let visibleCategory = values.min(by: { $0.value < $1.value })?.key {
            selectedCategory = visibleCategory
        }
    }

    
    func getProducts(for category: String) -> [Ponchi] {
        ponchis.filter {
            $0.category.rawValue == category
        }
    }
    
    func selectedTab(_ index: Int) {
        selectedTab = index
    }
    
    func selectSegment(index: Int) {
        selectedSegment = index
    }
    
    func getCategory() -> [String] {
        MockPonchiData.all.map { $0.category.rawValue }.sorted()
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

    func isOptionSelected(for category: Topping) -> Bool {
       guard let availableToppings = availableToppings else { return false }
       if let category = availableToppings.first(where: { $0.category == category.category }) {
           return category.options.contains(where: { $0.isSelected })
       }
       return false
   }
    
    func addToOrder(order: Cart) {
        if let selectedPonchi {
            order.addItem(selectedPonchi)
        }
    }
}


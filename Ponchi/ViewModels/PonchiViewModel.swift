//
//  PonchiViewModel.swift
//  Ponchi
//
//  Created by mary romanova on 15.12.2024.
//

import Foundation
import SwiftUI

final class PonchiViewModel: ObservableObject {
    // MARK: - Menu State

    @Published var ponchis: [Ponchi] = []
    @Published var isShowingDetails = false
    @Published var selectedTab = 0
    @Published var selectedCategory: Category? {
        didSet {
            AppSettings.shared.lastSelectedCategory = selectedCategory
        }
    }
    @Published var selectedIndex = 0
    @Published var isShownCups = false

    // MARK: - Product Detail State

    @Published var sizes: [Size] = Size.allCases
    @Published var selectedSize: Size? = .medium
    @Published var availableToppings: [Topping]?
    @Published var selectedPonchi: Ponchi? {
        didSet {
            syncSelectionState()
        }
    }
    @Published var comment = ""
    @Published var isAddShown = false

    // MARK: - Cart State

    @Published var animatedPrice: [Int] = []
    @Published var editedItemIndex: Int?

    // MARK: - Loading State

    @Published var isLoading = false
    @Published var showOfflineBanner = false
    @Published var offlineBannerText = ""

    private let loadMenuUseCase: LoadMenuUseCase
    private let bannerHideDelay: UInt64 = 2_500_000_000

    init(loadMenuUseCase: LoadMenuUseCase) {
        self.loadMenuUseCase = loadMenuUseCase
        self.selectedCategory = AppSettings.shared.lastSelectedCategory
    }
}

// MARK: - Computed Properties

extension PonchiViewModel {
    var hasTeaType: Bool {
        selectedPonchi?.selectedTeaType != nil
    }

    var hasMultipleSizes: Bool {
        guard let selectedPonchi else { return false }
        return selectedPonchi.size != .noSize && (selectedPonchi.fixedSizes?.count ?? 0) > 1
    }

    var selectedTeaBinding: Binding<TeaType> {
        Binding(
            get: {
                self.selectedPonchi?.selectedTeaType ?? .earlGrey
            },
            set: { newValue in
                guard var ponchi = self.selectedPonchi else { return }
                ponchi.selectedTeaType = newValue
                self.selectedPonchi = ponchi
            }
        )
    }

    var availableSizes: [Size] {
        if let selectedPonchi, let fixedSizes = selectedPonchi.fixedSizes {
            return fixedSizes.map(\.volume)
        }

        return Size.allCases.filter { $0 != .noSize }
    }

    var upsellItems: [Ponchi] {
        guard let selectedPonchi else { return [] }

        let relatedItems = ponchis.filter { selectedPonchi.isDrink ? $0.isFood : $0.isDrink }
        return Array(relatedItems.shuffled().prefix(3))
    }

    var newCategories: [Category] {
        Category.allCases
    }
}

// MARK: - Menu Actions

extension PonchiViewModel {
    func getProducts(for category: String) -> [Ponchi] {
        ponchis.filter { $0.category.rawValue == category }
    }

    func selectedTab(_ index: Int) {
        selectedTab = index
    }

    @MainActor
    func loadPonchi() async {
        isLoading = true
        defer { isLoading = false }

        do {
            let result = try await loadMenuUseCase.execute()
            ponchis = result.items

            if let message = result.message {
                presentOfflineBanner(message)
            } else {
                withAnimation(.easeInOut(duration: 0.25)) {
                    showOfflineBanner = false
                }
            }
        } catch {
            presentOfflineBanner("Сеть недоступна. Загружены резервные данные.")
        }
    }
}

// MARK: - Product Customization

extension PonchiViewModel {
    func selectSize(_ size: Size) {
        guard var currentPonchi = selectedPonchi else { return }

        currentPonchi.size = size
        selectedPonchi = currentPonchi
        selectedSize = size
        calculateTotalPrice()
    }

    func toggleToppingSelection(for option: ToppingOption, in category: Topping) {
        guard var updatedToppings = availableToppings, var currentPonchi = selectedPonchi else { return }
        guard let categoryIndex = updatedToppings.firstIndex(where: { $0.id == category.id }) else { return }

        for index in updatedToppings[categoryIndex].options.indices {
            updatedToppings[categoryIndex].options[index].isSelected = false
        }

        if let optionIndex = updatedToppings[categoryIndex].options.firstIndex(where: { $0.id == option.id }) {
            updatedToppings[categoryIndex].options[optionIndex].isSelected = true
        }

        currentPonchi.availableToppings = updatedToppings
        selectedPonchi = currentPonchi
        availableToppings = updatedToppings

        calculateTotalPrice()
    }
}

// MARK: - Cart Actions

extension PonchiViewModel {
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

    func confirmAddOrder(for cart: Cart) {
        if editedItemIndex != nil {
            saveChanges(to: cart)
        } else {
            addNewItem(to: cart)
        }
    }
}

// MARK: - Private Helpers

private extension PonchiViewModel {
    func syncSelectionState() {
        guard let selectedPonchi else { return }

        availableToppings = selectedPonchi.availableToppings
        selectedSize = selectedPonchi.size ?? .medium
        calculateTotalPrice()
    }

    func calculateTotalPrice() {
        guard let currentPonchi = selectedPonchi else { return }

        DispatchQueue.main.async {
            withAnimation {
                self.animatePriceChange(to: currentPonchi.totalPrice)
            }
        }
    }

    func getDigits(from number: Int) -> [Int] {
        String(number).compactMap(\.wholeNumberValue)
    }

    func addToOrder(_ cart: Cart) {
        guard let selectedPonchi else { return }
        cart.addItem(selectedPonchi)
    }

    func saveChanges(to cart: Cart) {
        guard let index = editedItemIndex,
              let updated = selectedPonchi,
              cart.items.indices.contains(index) else {
            addToOrder(cart)
            editedItemIndex = nil
            return
        }

        cart.items[index] = updated
        editedItemIndex = nil
    }

    func addNewItem(to cart: Cart) {
        guard var ponchi = selectedPonchi else { return }

        ponchi.quantity = 1
        cart.addItem(ponchi)
    }

    @MainActor
    func presentOfflineBanner(_ message: String) {
        offlineBannerText = message

        withAnimation(.easeInOut(duration: 0.25)) {
            showOfflineBanner = true
        }

        Task {
            try? await Task.sleep(nanoseconds: bannerHideDelay)
            await MainActor.run {
                withAnimation(.easeInOut(duration: 0.25)) {
                    showOfflineBanner = false
                }
            }
        }
    }
}

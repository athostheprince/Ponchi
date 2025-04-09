//
//  PonchiModel.swift
//  Ponchi
//
//  Created by mary romanova on 24.11.2024.
//

import Foundation


struct Ponchi: Identifiable, Codable, Equatable {
    var id: String { generateID() }
    var name: String
    var category: Category
    var basePrice: Int
    var image: String
    var description: String
    var size: Size? = .medium
    var calories: String
    var weight: String?
    var quantity = 1
    
    var ml: String {
        switch size {
        case .small: return "200 мл"
        case .medium: return "300 мл"
        case .large: return "400 мл"
        default: return ""
        }
    }
    
    var fixedSizes: [SizePicker]?
    
    var hasTopping: Bool {
        availableToppings != nil
    }
    
    var availableToppings: [Topping]?
    
    var selectedToppings: [ToppingOption] {
        availableToppings?.flatMap { $0.options.filter { $0.isSelected } } ?? []
    }
    

    // Цена выбранного размера
    var currentSizePrice: Int {
        guard let size = size else { return basePrice }
        return fixedSizes?.first(where: { $0.volume == size })?.price ?? basePrice
    }
    
    // Цена молока (50 для любого, кроме коровьего)
    var milkPrice: Int {
        let milkTopping = selectedToppings.first { topping in
            availableToppings?.first { $0.category == .milk }?.options.contains { $0.id == topping.id } ?? false
        }
        return (milkTopping?.name != "коровье молоко") ? 50 : 0
    }
    
    // Цена сиропа (20 для любого, кроме "без сиропа")
    var syrupPrice: Int {
        let syrupTopping = selectedToppings.first { topping in
            availableToppings?.first { $0.category == .syrop }?.options.contains { $0.id == topping.id } ?? false
        }
        return (syrupTopping?.name != "без сиропа") ? 20 : 0
    }
    
    // Итоговая цена
    var totalPrice: Int {
        let price = currentSizePrice + milkPrice + syrupPrice
        return price * quantity
    }
    
    // Описание выбранных топпингов
    var selectedToppingsDescription: String {
        let grouped = Dictionary(grouping: selectedToppings) { option in
            availableToppings?.first { $0.options.contains(where: { $0.id == option.id }) }?.category
        }
        
        return grouped.map { (category, options) in
            let topOption = options.max(by: { $0.price < $1.price })?.name ?? ""
            return "\(category?.rawValue ?? ""): \(topOption)"
        }.joined(separator: ", ")
    }

    static func == (lhs: Ponchi, rhs: Ponchi) -> Bool {
        return lhs.isEquivalent(to: rhs)
    }
    
    func isEquivalent(to other: Ponchi) -> Bool {
        return self.name == other.name &&
        self.size == other.size &&
        self.selectedToppings == other.selectedToppings
    }
    
    func generateID() -> String {
        let toppingsString = selectedToppings.map { $0.name }.joined(separator: ",")
        return "\(name)-\(size?.rawValue ?? "")-\(toppingsString)"
    }

    func withUpdatedToppings(_ toppings: [Topping]) -> Ponchi {
        var updated = self
        updated.availableToppings = toppings
        return updated
    }
}



struct SizePicker: Codable, Identifiable, Equatable {
    var id = UUID()
    var volume: Size
    var price: Int
}

struct Topping: Codable, Identifiable, Equatable {
    var id = UUID()
    var category: ToppingCategory
    var options: [ToppingOption]
}

struct ToppingOption: Codable, Identifiable, Equatable {
    var id = UUID()
    var name: String
    var price: Int
    var isSelected: Bool = false
}

enum ToppingCategory: String, Codable, CaseIterable {
    case milk = "молоко"
    case syrop = "сироп"
    case temperature = "лед"
    case aditionaly = "дополнительно"
}

enum Size: String, Codable, CaseIterable, Identifiable {
    
    var id: String { rawValue }
    
    case small = "S"
    case medium = "M"
    case large = "L"
    case noSize = ""
    
    static var allCases: [Size] {
        return [.small, .medium, .large, .noSize]
    }
}

enum Category: String, Codable, CaseIterable, Identifiable {
    
    var id: String { rawValue }
    
    case new = "Новинки"
    case coffee = "Классика"
    case notCoffee = "Не кофе"
    case food = "Перекусить"
    case signatureDrincks = "Авторские напитки"
    
    var items: [String] {
        MockPonchiData.all.filter { $0.category == self }.map { $0.name }
    }
}

struct ToppingStore {
    static let availableToppings: [Topping] = [
        Topping(category: .milk, options: [
            ToppingOption(name: "кокосовое молоко", price: 50),
            ToppingOption(name: "миндальное молоко", price: 50),
            ToppingOption(name: "банановое молоко", price: 50),
            ToppingOption(name: "коровье молоко", price: 0)
            ]),
        Topping(category: .syrop, options: [
            ToppingOption(name: "соленая карамель", price: 20),
            ToppingOption(name: "ваниль", price: 20),
            ToppingOption(name: "попкорн", price: 20),
            ToppingOption(name: "без сиропа", price: 0)
        ]),
        Topping(category: .temperature, options: [
            ToppingOption(name: "горячий", price: 0),
            ToppingOption(name: "холодный", price: 0)
        ]),
        Topping(category: .aditionaly, options: [
            ToppingOption(name: "молоко", price: 30),
            ToppingOption(name: "сливки", price: 40),
            ToppingOption(name: "взбитые сливки", price: 55),
            ToppingOption(name: "корица", price: 0),
            ToppingOption(name: "лимон", price: 10),
            ToppingOption(name: "без всего", price: 0)
        ]),
    ]
}

struct MockPonchiData {
    static let cappuccino = Ponchi(
        name: "Капучино",
        category: .coffee,
        basePrice: 149,
        image: "capuccino",
        description: "Капучино — это гармоничное сочетание эспрессо, горячего молока и нежной молочной пенки.Капучино — это гармоничное сочетание эспрессо, горячего молока и нежной молочной пенки.Капучино — это гармоничное сочетание эспрессо, горячего молока и нежной молочной пенки.Капучино — это гармоничное сочетание эспрессо, горячего молока и нежной молочной пенки.Капучино — это гармоничное сочетание эспрессо, горячего молока и нежной молочной пенки.Капучино — это гармоничное сочетание эспрессо, горячего молока и нежной молочной пенки.",
        calories: "130 ккал",
        fixedSizes: [
            SizePicker(volume: .small, price: 149),
            SizePicker(volume: .medium, price: 179),
            SizePicker(volume: .large, price: 229)
        ],
        availableToppings: ToppingStore.availableToppings
    )
    
    static let americano = Ponchi(
        name: "Американо",
        category: .coffee,
        basePrice: 125,
        image: "americano",
        description: "Американо — это классический черный кофе, приготовленный путем добавления горячей воды к порции эспрессо.",
        calories: "10 ккал",
        fixedSizes: [
            SizePicker(volume: .small, price: 125),
            SizePicker(volume: .medium, price: 159)
        ],
        availableToppings: ToppingStore.availableToppings
    )
    
    static let espresso = Ponchi(
        name: "Эспрессо",
        category: .coffee,
        basePrice: 99,
        image: "espresso",
        description: "Эспрессо — крепкий и насыщенный напиток, который подается в небольшом объеме.",
        calories: "10 ккал",
        fixedSizes: [
            SizePicker(volume: .small, price: 99),
            SizePicker(volume: .medium, price: 125)
        ],
        availableToppings: ToppingStore.availableToppings
    )
    
    static let latte = Ponchi(
        name: "Латте",
        category: .coffee,
        basePrice: 179,
        image: "latte",
        description: "Латте — классический молочный напиток с эспрессо, который отличается мягким вкусом и легкой сливочной текстурой.",
        calories: "170 ккал",
        fixedSizes: [
            SizePicker(volume: .medium, price: 179),
            SizePicker(volume: .large, price: 229)
        ],
        availableToppings: ToppingStore.availableToppings
    )
    
    static let raf = Ponchi(
        name: "Раф",
        category: .coffee,
        basePrice: 259,
        image: "raf",
        description: "Раф — нежный кофейный напиток, приготовленный с добавлением сливок, сахара и ванильного сиропа.",
        calories: "250 ккал",
        fixedSizes: [
            SizePicker(volume: .medium, price: 259) // Только один размер
        ],
        availableToppings: ToppingStore.availableToppings
    )
    
    static let flat = Ponchi(
        name: "Флэт-уайт",
        category: .coffee,
        basePrice: 169,
        image: "flat",
        description: "Флэт-уайт — это крепкий кофе с насыщенным вкусом, созданный на основе двойного эспрессо и небольшого количества взбитого молока.",
        calories: "140 ккал",
        fixedSizes: [
            SizePicker(volume: .small, price: 169) // Только один размер
        ],
        availableToppings: ToppingStore.availableToppings
    )
    
    static let filter = Ponchi(
        name: "Фильтр",
        category: .coffee,
        basePrice: 149, 
        image: "filter",
        description: "Фильтр-кофе — это классический способ заваривания кофе, который подчеркивает чистоту вкуса и аромата.",
        calories: "10 ккал",
        fixedSizes: [
            SizePicker(volume: .small, price: 149),
            SizePicker(volume: .medium, price: 199)
        ],
        availableToppings: ToppingStore.availableToppings
    )
    
    static let bananaRaf = Ponchi(
        name: "Бананово-пряный раф",
        category: .signatureDrincks,
        basePrice: 250,
        image: "",
        description: "",
        calories: "270 ккал",
        fixedSizes: [
            SizePicker(volume: .medium, price: 250)
        ])
    
    static let pampkinRaf = Ponchi(
        name: "Тыквенный раф",
        category: .new,
        basePrice: 359,
        image: "",
        description: "",
        calories: "280 ккал",
        fixedSizes: [
            SizePicker(volume: .medium, price: 359)
        ])
    
    static let cheezeSanta = Ponchi(
        name: "Сырный Санта",
        category: .new,
        basePrice: 349,
        image: "",
        description: "",
        calories: "280 ккал",
        fixedSizes: [
            SizePicker(volume: .medium, price: 349)
        ])
    
    static let canadaRaf = Ponchi(
        name: "Канадский раф",
        category: .new,
        basePrice: 349,
        image: "",
        description: "",
        calories: "280 ккал",
        fixedSizes: [
            SizePicker(volume: .medium, price: 349)
        ])
    
    static let spicyPear = Ponchi(
        name: "Пряная груша",
        category: .new,
        basePrice: 359,
        image: "",
        description: "",
        calories: "280 ккал",
        fixedSizes: [
            SizePicker(volume: .medium, price: 359)
        ])
    
    static let nutsMokka = Ponchi(
        name: "Ореховый мокко",
        category: .signatureDrincks,
        basePrice: 359,
        image: "",
        description: "",
        calories: "280 ккал",
        fixedSizes: [
            SizePicker(volume: .medium, price: 359)
        ])
    
    static let pinkMatcha = Ponchi(
        name: "Розовая матча",
        category: .signatureDrincks,
        basePrice: 339,
        image: "",
        description: "",
        calories: "280 ккал",
        fixedSizes: [
            SizePicker(volume: .medium, price: 339)
        ])
    
    static let coconutMatcha = Ponchi(
        name: "Кокосовая матча",
        category: .signatureDrincks,
        basePrice: 339,
        image: "",
        description: "",
        calories: "280 ккал",
        fixedSizes: [
            SizePicker(volume: .medium, price: 339)
        ])
    
    static let iceLatte = Ponchi(
        name: "Айс-латте",
        category: .signatureDrincks,
        basePrice: 239,
        image: "",
        description: "",
        calories: "280 ккал",
        fixedSizes: [
            SizePicker(volume: .medium, price: 239)
        ])
    
    static let cacao = Ponchi(
        name: "Какао",
        category: .notCoffee,
        basePrice: 149,
        image: "",
        description: "",
        calories: "280 ккал",
        fixedSizes: [
            SizePicker(volume: .medium, price: 159)
        ])
    
    static let matchaLatte = Ponchi(
        name: "Матча латте",
        category: .notCoffee,
        basePrice: 229,
        image: "",
        description: "",
        calories: "280 ккал",
        fixedSizes: [
            SizePicker(volume: .medium, price: 229)
        ])
    
    static let lemonade = Ponchi(
        name: "Лимонад",
        category: .notCoffee,
        basePrice: 239,
        image: "",
        description: "",
        calories: "280 ккал",
        fixedSizes: [
            SizePicker(volume: .medium, price: 239)
        ])
    
    static let milkShake = Ponchi(
        name: "Молочный коктейль",
        category: .notCoffee,
        basePrice: 159,
        image: "",
        description: "",
        calories: "280 ккал",
        fixedSizes: [
            SizePicker(volume: .medium, price: 159)
        ])
    
    static let earlGray = Ponchi(
        name: "Эрл Грей",
        category: .notCoffee,
        basePrice: 199,
        image: "",
        description: "",
        calories: "280 ккал",
        fixedSizes: [
            SizePicker(volume: .small, price: 169),
            SizePicker(volume: .medium, price: 199)
        ])
    
    static let raspberriesWithRosemary = Ponchi(
        name: "Малина с розмарином",
        category: .notCoffee,
        basePrice: 199,
        image: "",
        description: "",
        calories: "280 ккал",
        fixedSizes: [
            SizePicker(volume: .small, price: 169),
            SizePicker(volume: .medium, price: 199)
        ])
    
    static let irishCream = Ponchi(
        name: "Ирландские сливки",
        category: .notCoffee,
        basePrice: 199,
        image: "",
        description: "",
        calories: "280 ккал",
        fixedSizes: [
            SizePicker(volume: .small, price: 169),
            SizePicker(volume: .medium, price: 199)
        ])
    
    static let spicyTea = Ponchi(
        name: "Пряный чай",
        category: .notCoffee,
        basePrice: 199,
        image: "",
        description: "",
        calories: "280 ккал",
        fixedSizes: [
            SizePicker(volume: .small, price: 169),
            SizePicker(volume: .medium, price: 199)
        ])
    
    static let cherryTea = Ponchi(
        name: "Вишневый чай",
        category: .notCoffee,
        basePrice: 199,
        image: "",
        description: "",
        calories: "280 ккал",
        fixedSizes: [
            SizePicker(volume: .small, price: 169),
            SizePicker(volume: .medium, price: 199)
        ])
    
    static let sencha = Ponchi(
        name: "Зеленый чай вечерний",
        category: .notCoffee,
        basePrice: 199,
        image: "",
        description: "",
        calories: "280 ккал",
        fixedSizes: [
            SizePicker(volume: .small, price: 169),
            SizePicker(volume: .medium, price: 199)
        ])
    
    static let sendwichWithHam = Ponchi(
        name: "Сэндвич с ветчиной",
        category: .food,
        basePrice: 320,
        image: "",
        description: "",
        calories: "280 ккал")
    
    static let sendwichWithSelmon = Ponchi(
        name: "Сэндвич с лососем",
        category: .food,
        basePrice: 359,
        image: "",
        description: "",
        calories: "280 ккал")
    
    static let sendwichWithAvocado = Ponchi(
        name: "Тосты с лососем и авокадо",
        category: .food,
        basePrice: 369,
        image: "",
        description: "",
        calories: "280 ккал")
    
    static let vienneseWaffle = Ponchi(
        name: "Венская вафля",
        category: .food,
        basePrice: 119,
        image: "",
        description: "",
        calories: "280 ккал")
    
    static let syrniki = Ponchi(
        name: "Сырники",
        category: .food,
        basePrice: 259,
        image: "",
        description: "",
        calories: "280 ккал",
        fixedSizes: [
            SizePicker(volume: .small, price: 189),
            SizePicker(volume: .medium, price: 259)
        ])
    
    static let muesly = Ponchi(
        name: "Мультизлаковые мюсли",
        category: .food,
        basePrice: 149,
        image: "",
        description: "",
        calories: "280 ккал")
    
    static let pancakes = Ponchi(
        name: "Оладьи",
        category: .food,
        basePrice: 109,
        image: "",
        description: "",
        calories: "280 ккал")
    
    static let all: [Ponchi] = [cappuccino, americano, espresso, latte, raf, flat, filter, bananaRaf, pampkinRaf, cheezeSanta, canadaRaf, spicyPear, nutsMokka, pinkMatcha, coconutMatcha, iceLatte, cacao, matchaLatte, lemonade, milkShake, earlGray,raspberriesWithRosemary, irishCream, spicyTea, cherryTea, sencha, sendwichWithHam, sendwichWithSelmon, sendwichWithAvocado, vienneseWaffle, muesly, pancakes, syrniki]
}

//
//  PonchiModel.swift
//  Ponchi
//
//  Created by mary romanova on 24.11.2024.
//

import Foundation
import SwiftUI

struct Ponchi: Identifiable, Codable, Equatable {
    var productId: String
    var id: String {
        let toppings = selectedToppings.map(\.name).joined(separator: ",")
        return "\(productId)-\(size?.rawValue ?? "")-\(toppings)"
    }

    // MARK: - Core

    var name: String
    var category: Category
    var basePrice: Int
    var image: String
    var images: [String]?
    var description: String
    var size: Size? = .medium
    var calories: String
    var weight: String?
    var quantity = 1
    var nutrition: Nutrition?
    var fixedSizes: [SizePicker]?
    var availableToppings: [Topping]?
    var drinkTag: [DrinkTag]?
    var foodTag: [FoodTag]?
    var teaType: [TeaType]?
    var selectedTeaType: TeaType?

    enum CodingKeys: String, CodingKey {
        case productId
        case name, category, basePrice, image, images, description
        case calories, weight, nutrition
        case fixedSizes, availableToppings
        case drinkTag, foodTag, teaType
    }
}

// MARK: - Presentation

extension Ponchi {
    var displayImage: String {
        selectedTeaType?.imageName ?? image
    }

    var ml: String {
        switch size {
        case .small: return "200 мл"
        case .medium: return "300 мл"
        case .large: return "400 мл"
        default: return ""
        }
    }
    
    var hasMultipleSizes: Bool {
        size != .noSize && (fixedSizes?.count ?? 0) > 1
    }

    var hasTopping: Bool {
        guard let available = availableToppings else { return false }
        return !available.isEmpty
    }

    var selectedToppingsDescription: String {
        let grouped = Dictionary(grouping: selectedToppings) { option in
            availableToppings?.first { $0.options.contains(where: { $0.id == option.id }) }?.category
        }
        return grouped.map { category, options in
            let topOption = options.max(by: { $0.price < $1.price })?.name ?? ""
            return "\(category?.rawValue ?? ""): \(topOption)"
        }.joined(separator: ", ")
    }

    var isDrink: Bool {
        category != .food
    }

    var isFood: Bool {
        category == .food
    }
}

// MARK: - Pricing

extension Ponchi {
    var currentSizePrice: Int {
        guard let size else { return basePrice }
        return fixedSizes?.first(where: { $0.volume == size })?.price ?? basePrice
    }

    var selectedToppings: [ToppingOption] {
        availableToppings?.flatMap { $0.options.filter(\.isSelected) } ?? []
    }

    var totalPrice: Int {
        let toppingsPrice = selectedToppings.reduce(0) { $0 + $1.price }
        return (currentSizePrice + toppingsPrice) * quantity
    }
}

// MARK: - Equatable

extension Ponchi {
    static func == (lhs: Ponchi, rhs: Ponchi) -> Bool {
        lhs.name == rhs.name &&
        lhs.size == rhs.size &&
        lhs.selectedToppings == rhs.selectedToppings
    }
}

struct Nutrition: Codable, Equatable {
    var proteins: String
    var fats: String
    var carbs: String
}


struct SizePicker: Codable, Identifiable, Equatable {
    var id: String
    var volume: Size
    var price: Int

    init(volume: Size, price: Int) {
        self.id = volume.rawValue
        self.volume = volume
        self.price = price
    }
}

struct Topping: Codable, Identifiable, Equatable {
    var id: String
    var category: ToppingCategory
    var options: [ToppingOption]
}

struct ToppingOption: Codable, Identifiable, Equatable {
    var id: String
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

enum TeaType: String, Codable, CaseIterable, Identifiable {
    
    case earlGrey = "Эрл Грей"
    case sencha = "Сенча"
    case irishCream = "Ирландские сливки"
    case raspberryRosemary = "Малина с розмарином"
    case cherry = "Вишней чай"
    case spicy = "Пряный чай"
    
    var id: String { rawValue }
    
    var imageName: String {
        switch self {
        case .cherry: return "вишневыйЧай"
        case .earlGrey: return "эрлГрей"
        case .sencha: return "сенча"
        case .irishCream: return "ирландскиеСливки"
        case .raspberryRosemary: return "малинаРозмарин"
        case .spicy: return "пряныйЧай"
        }
    }
}

enum Category: String, Codable, CaseIterable, Identifiable {
    var id: String { rawValue }

    case new = "Новинки"
    case coffee = "Классика"
    case notCoffee = "Не кофе"
    case food = "Перекусить"
    case signatureDrincks = "Авторские напитки"
}

struct ToppingStore {
    static let availableToppings: [Topping] = [
        Topping(id: "milk", category: .milk, options: [
            ToppingOption(id: "milk_coconut", name: "кокосовое молоко", price: 50),
            ToppingOption(id: "milk_almond", name: "миндальное молоко", price: 50),
            ToppingOption(id: "milk_banana", name: "банановое молоко", price: 50),
            ToppingOption(id: "milk_cow", name: "коровье молоко", price: 0)
        ]),
        Topping(id: "syrup", category: .syrop, options: [
            ToppingOption(id: "syrup_salted_caramel", name: "соленая карамель", price: 20),
            ToppingOption(id: "syrup_vanilla", name: "ваниль", price: 20),
            ToppingOption(id: "syrup_popcorn", name: "попкорн", price: 20),
            ToppingOption(id: "syrup_none", name: "без сиропа", price: 0)
        ]),
        Topping(id: "temperature", category: .temperature, options: [
            ToppingOption(id: "temp_hot", name: "горячий", price: 0),
            ToppingOption(id: "temp_cold", name: "холодный", price: 0)
        ]),
        Topping(id: "additional", category: .aditionaly, options: [
            ToppingOption(id: "extra_milk", name: "молоко", price: 30),
            ToppingOption(id: "extra_cream", name: "сливки", price: 40),
            ToppingOption(id: "extra_whipped_cream", name: "взбитые сливки", price: 55),
            ToppingOption(id: "extra_cinnamon", name: "корица", price: 0),
            ToppingOption(id: "extra_lemon", name: "лимон", price: 10),
            ToppingOption(id: "extra_none", name: "без всего", price: 0)
        ]),
    ]
}

enum DrinkTag: String, CaseIterable, Identifiable, Codable {
    case молочнаяПенка = "Молочная пенка"
    case сбалансированный = "Сбалансированный"
    case классика = "Классика"
    case освежающий = "Освежающий"
    case сладкий = "Сладкий"
    case холодный = "Холодный"
    case тёплый = "Тёплый"
    case фруктовый = "Фруктовый"
    case насыщенный = "Насыщенный"
    case лёгкий = "Лёгкий"
    case ореховый = "Ореховый"
    case сливочный = "Сливочный"
    case ванильный = "Ванильный"
    case травяной = "Травяной"
    case цитрусовый = "Цитрусовый"
    case шоколадный = "Шоколадный"
    case бодрящий = "Бодрящий"
    case пряный = "Пряный"
    case кремовый = "Кремовый"
    case густой = "Густой"
    case бархатный = "Бархатный"
    case матча = "Матча"
    case необычно = "Необычно"


    var id: String { rawValue }

    var icon: String {
        switch self {
        case .молочнаяПенка: return "cloud.fill"
        case .сбалансированный: return "scalemass"
        case .классика: return "cup.and.saucer.fill"
        case .освежающий: return "sparkle"
        case .сладкий: return "cube.fill"
        case .холодный: return "snowflake"
        case .тёплый: return "thermometer"
        case .фруктовый: return "applelogo"
        case .насыщенный: return "drop.triangle"
        case .лёгкий: return "wind"
        case .ореховый: return "leaf"
        case .сливочный: return "sun.max"
        case .ванильный: return "sparkles"
        case .травяной: return "leaf.fill"
        case .цитрусовый: return "sun.dust"
        case .шоколадный: return "flame"
        case .бодрящий: return "bolt.fill"
        case .пряный: return "tropicalstorm"
        case .кремовый: return "circle.lefthalf.fill"
        case .густой: return "drop.fill"
        case .бархатный: return "moon.fill"
        case .матча: return "leaf.circle.fill"
        case .необычно: return "wand.and.stars"
        }
    }

    var color: Color {
        switch self {
        case .молочнаяПенка: return Color(hex: "#EFE8DC")
        case .сбалансированный: return Color(hex: "#D8D2C4")
        case .классика: return Color(hex: "#C2B3A3")
        case .освежающий: return Color(hex: "#C8E4D4")
        case .сладкий: return Color(hex: "#F4D4D4")
        case .холодный: return Color(hex: "#D8E9F1")
        case .тёплый: return Color(hex: "#E7D6C5")
        case .фруктовый: return Color(hex: "#F9D8B4")
        case .насыщенный: return Color(hex: "#B29C8A")
        case .лёгкий: return Color(hex: "#E4E6D9")
        case .ореховый: return Color(hex: "#D1BFA3")
        case .сливочный: return Color(hex: "#F1DEC9")
        case .ванильный: return Color(hex: "#F8EFD4")
        case .травяной: return Color(hex: "#D2E0C4")
        case .цитрусовый: return Color(hex: "#FFE9BB")
        case .шоколадный: return Color(hex: "#A98C73")
        case .бодрящий: return Color(hex: "#EBD6A8")
        case .пряный: return Color(hex: "#D5B8A1")
        case .кремовый: return Color(hex: "#F4E9DD")
        case .густой: return Color(hex: "#D0C4B1")
        case .бархатный: return Color(hex: "#C8B8A9")
        case .матча: return Color(hex: "#B7D7B1")
        case .необычно: return Color(hex: "#D4CCE3")

        }
    }
}

enum FoodTag: String, CaseIterable, Identifiable, Codable {
    case сытная = "Сытная"
    case сладкая = "Сладкая"
    case хрустящая = "Хрустящая"
    case горячая = "Горячая"
    case тёплая = "Тёплая"
    case прохладная = "Прохладная"
    case классика = "Классика"
    case вегетарианская = "Вегетарианская"
    case кремовая = "Кремовая"
    case сырная = "Сырная"
    case хендмейд = "Хендмейд"
    case наЗавтрак = "На завтрак"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .сытная: return "takeoutbag.and.cup.and.straw"
        case .сладкая: return "birthday.cake.fill"
        case .хрустящая: return "frying.pan"
        case .горячая: return "flame.fill"
        case .тёплая: return "thermometer.medium"
        case .прохладная: return "snowflake"
        case .классика: return "leaf"
        case .вегетарианская: return "leaf.fill"
        case .кремовая: return "drop"
        case .сырная: return "cheese"
        case .хендмейд: return "hammer.fill"
        case .наЗавтрак: return "sunrise.fill"
        }
    }

    var color: Color {
        switch self {
        case .сытная: return Color(hex: "#E4CBB0")
        case .сладкая: return Color(hex: "#F7D6DA")
        case .хрустящая: return Color(hex: "#E8D3B2")
        case .горячая: return Color(hex: "#F6B291")
        case .тёплая: return Color(hex: "#F0DDC1")
        case .прохладная: return Color(hex: "#D8EDF2")
        case .классика: return Color(hex: "#DAD2BE")
        case .вегетарианская: return Color(hex: "#C9E1BE")
        case .кремовая: return Color(hex: "#F3E6D6")
        case .сырная: return Color(hex: "#FFF3B0")
        case .хендмейд: return Color(hex: "#D5C4B6")
        case .наЗавтрак: return Color(hex: "#FFE8B7")
        }
    }
}

struct MockPonchiData {
    
    static let cappuccino = Ponchi(
        productId: "cappuccino",
        name: "Капучино",
        category: .coffee,
        basePrice: 149,
        image: "Капуч",
        description: "Капучино — это гармоничное сочетание эспрессо, горячего молока и нежной молочной пенки.",
        calories: "130 ккал",
        nutrition: Nutrition(proteins: "6 г", fats: "5 г", carbs: "12 г"),
        fixedSizes: [
            SizePicker(volume: .small, price: 149),
            SizePicker(volume: .medium, price: 179),
            SizePicker(volume: .large, price: 229)
        ],
        availableToppings: ToppingStore.availableToppings,
        drinkTag: [.сбалансированный, .классика, .молочнаяПенка]
    )
    
    static let americano = Ponchi(
        productId: "americano",
        name: "Американо",
        category: .coffee,
        basePrice: 125,
        image: "Американо",
        description: "Американо — это классический черный кофе, приготовленный путем добавления горячей воды к порции эспрессо.",
        calories: "10 ккал",
        nutrition: Nutrition(proteins: "0 г", fats: "0 г", carbs: "1 г"),
        fixedSizes: [
            SizePicker(volume: .small, price: 125),
            SizePicker(volume: .medium, price: 159)
        ],
        availableToppings: ToppingStore.availableToppings,
        drinkTag: [.классика, .тёплый]
    )
    
    static let espresso = Ponchi(
        productId: "espresso",
        name: "Эспрессо",
        category: .coffee,
        basePrice: 99,
        image: "эспрессо",
        description: "Эспрессо — крепкий и насыщенный напиток, который подается в небольшом объеме.",
        calories: "10 ккал",
        nutrition: Nutrition(proteins: "1 г", fats: "0 г", carbs: "1 г"),
        fixedSizes: [
            SizePicker(volume: .small, price: 99),
            SizePicker(volume: .medium, price: 125)
        ],
        availableToppings: ToppingStore.availableToppings,
        drinkTag: [.классика, .бодрящий]
    )
    
    static let bamble = Ponchi(
        productId: "bamble",
        name: "Бамбл-кофе",
        category: .signatureDrincks,
        basePrice: 250,
        image: "Бамбл",
        description: "Бамбл - это насыщенный эспрессо в сочетании с апельсиновым соком",
        calories: "10 ккал",
        nutrition: Nutrition(proteins: "1 г", fats: "0 г", carbs: "1 г"),
        availableToppings: ToppingStore.availableToppings,
        drinkTag: [.фруктовый, .бодрящий]
    )
    
    static let tonic = Ponchi(
        productId: "tonic",
        name: "Эспрессо-тоник",
        category: .signatureDrincks,
        basePrice: 250,
        image: "ЭспрессоТоник",
        description: "Эспрессо-тоник - это насыщенный эспрессо в сочетании с швепсом",
        calories: "250 ккал",
        nutrition: Nutrition(proteins: "1 г", fats: "0 г", carbs: "1 г"),
        availableToppings: ToppingStore.availableToppings,
        drinkTag: [.фруктовый, .бодрящий]
    )
    
    static let latte = Ponchi(
        productId: "latte",
        name: "Латте",
        category: .coffee,
        basePrice: 179,
        image: "Латте",
        description: "Латте — классический молочный напиток с эспрессо, который отличается мягким вкусом и легкой сливочной текстурой.",
        calories: "170 ккал",
        nutrition: Nutrition(proteins: "7 г", fats: "6 г", carbs: "15 г"),
        fixedSizes: [
            SizePicker(volume: .medium, price: 179),
            SizePicker(volume: .large, price: 229)
        ],
        availableToppings: ToppingStore.availableToppings,
        drinkTag: [.классика, .тёплый, .лёгкий]
    )
    
    static let raf = Ponchi(
        productId: "raf",
        name: "Раф",
        category: .coffee,
        basePrice: 259,
        image: "раф",
        description: "Раф — нежный кофейный напиток, приготовленный с добавлением сливок, сахара и ванильного сиропа.",
        calories: "250 ккал",
        nutrition: Nutrition(proteins: "6 г", fats: "12 г", carbs: "25 г"),
        fixedSizes: [SizePicker(volume: .medium, price: 259)],
        availableToppings: ToppingStore.availableToppings,
        drinkTag: [.бархатный, .ванильный, .кремовый]
    )
    
    static let flat = Ponchi(
        productId: "flat",
        name: "Флэт-уайт",
        category: .coffee,
        basePrice: 169,
        image: "флэтУайт",
        description: "Флэт-уайт — это крепкий кофе с насыщенным вкусом, созданный на основе двойного эспрессо и небольшого количества взбитого молока.",
        calories: "140 ккал",
        nutrition: Nutrition(proteins: "6 г", fats: "5 г", carbs: "10 г"),
        fixedSizes: [SizePicker(volume: .small, price: 169)],
        availableToppings: ToppingStore.availableToppings,
        drinkTag: [.бодрящий, .молочнаяПенка, .насыщенный]
    )
    
    static let filter = Ponchi(
        productId: "filter",
        name: "Фильтр",
        category: .coffee,
        basePrice: 149,
        image: "Фильтр",
        description: "Фильтр-кофе — это классический способ заваривания кофе, который подчеркивает чистоту вкуса и аромата.",
        calories: "10 ккал",
        nutrition: Nutrition(proteins: "1 г", fats: "0 г", carbs: "2 г"),
        fixedSizes: [
            SizePicker(volume: .small, price: 149),
            SizePicker(volume: .medium, price: 199)
        ],
        availableToppings: ToppingStore.availableToppings,
        drinkTag: [.классика, .тёплый, .бодрящий]
    )
    
    static let bananaRaf = Ponchi(
        productId: "bananaRaf",
        name: "Бананово-пряный латте",
        category: .new,
        basePrice: 250,
        image: "БанановоПряныйЛатте",
        description: "",
        calories: "270 ккал",
        nutrition: Nutrition(proteins: "5 г", fats: "11 г", carbs: "32 г"),
        fixedSizes: [SizePicker(volume: .medium, price: 250)],
        drinkTag: [.бархатный, .пряный, .сливочный]
    )
    
    static let pampkinRaf = Ponchi(
        productId: "pampkinRaf",
        name: "Тыквенный раф",
        category: .new,
        basePrice: 359,
        image: "ТыквеныйРаф",
        description: "",
        calories: "280 ккал",
        nutrition: Nutrition(proteins: "6 г", fats: "12 г", carbs: "34 г"),
        fixedSizes: [SizePicker(volume: .medium, price: 359)],
        drinkTag: [.пряный, .сливочный]
    )
    
    static let cheezeSanta = Ponchi(
        productId: "cheezeSanta",
        name: "Сырный Санта",
        category: .new,
        basePrice: 349,
        image: "СырныйСанта",
        description: "",
        calories: "280 ккал",
        nutrition: Nutrition(proteins: "8 г", fats: "18 г", carbs: "15 г"),
        fixedSizes: [SizePicker(volume: .medium, price: 349)],
        drinkTag: [.бархатный, .кремовый]
    )
    
    static let canadaRaf = Ponchi(
        productId: "canadaRaf",
        name: "Канадский раф",
        category: .new,
        basePrice: 349,
        image: "КанадскийРаф",
        description: "",
        calories: "280 ккал",
        nutrition: Nutrition(proteins: "6 г", fats: "12 г", carbs: "30 г"),
        fixedSizes: [SizePicker(volume: .medium, price: 349)],
        drinkTag: [.тёплый, .сливочный]
    )
    
    static let spicyPear = Ponchi(
        productId: "spicyPear",
        name: "Пряная груша",
        category: .notCoffee,
        basePrice: 359,
        image: "ГрушевыйРаф",
        description: "",
        calories: "280 ккал",
        nutrition: Nutrition(proteins: "2 г", fats: "8 г", carbs: "40 г"),
        fixedSizes: [SizePicker(volume: .medium, price: 359)],
        drinkTag: [.фруктовый, .пряный]
    )
    
    static let nutsMokka = Ponchi(
        productId: "nutsMokka",
        name: "Ореховый мокко",
        category: .signatureDrincks,
        basePrice: 359,
        image: "ОреховыйМокко",
        description: "",
        calories: "280 ккал",
        nutrition: Nutrition(proteins: "6 г", fats: "12 г", carbs: "32 г"),
        fixedSizes: [SizePicker(volume: .medium, price: 359)],
        drinkTag: [.шоколадный, .ореховый]
    )
    
    static let pinkMatcha = Ponchi(
        productId: "pinkMatcha",
        name: "Розовая матча",
        category: .signatureDrincks,
        basePrice: 339,
        image: "розоваяМатча",
        description: "",
        calories: "280 ккал",
        nutrition: Nutrition(proteins: "4 г", fats: "6 г", carbs: "28 г"),
        fixedSizes: [SizePicker(volume: .medium, price: 339)],
        drinkTag: [.матча, .травяной, .лёгкий, .необычно]
    )
    
    static let coconutMatcha = Ponchi(
        productId: "coconutMatcha",
        name: "Кокосовая матча",
        category: .signatureDrincks,
        basePrice: 339,
        image: "кокосоваяМатча",
        description: "",
        calories: "280 ккал",
        nutrition: Nutrition(proteins: "4 г", fats: "8 г", carbs: "26 г"),
        fixedSizes: [SizePicker(volume: .medium, price: 339)],
        drinkTag: [.матча, .ореховый, .сладкий]
    )
    
    static let iceLatte = Ponchi(
        productId: "icedLatte",
        name: "Айс-латте",
        category: .signatureDrincks,
        basePrice: 239,
        image: "айс-латте",
        description: "",
        calories: "280 ккал",
        nutrition: Nutrition(proteins: "6 г", fats: "5 г", carbs: "15 г"),
        fixedSizes: [SizePicker(volume: .medium, price: 239)],
        drinkTag: [.лёгкий, .освежающий, .холодный]
    )
    
    static let cacao = Ponchi(
        productId: "cacao",
        name: "Какао",
        category: .notCoffee,
        basePrice: 149,
        image: "какао",
        description: "",
        calories: "280 ккал",
        nutrition: Nutrition(proteins: "5 г", fats: "8 г", carbs: "28 г"),
        fixedSizes: [SizePicker(volume: .medium, price: 159)],
        drinkTag: [.ореховый, .тёплый, .сладкий]
    )
    
    static let matchaLatte = Ponchi(
        productId: "matchaLatte",
        name: "Матча латте",
        category: .notCoffee,
        basePrice: 229,
        image: "матчаЛатте",
        description: "",
        calories: "280 ккал",
        nutrition: Nutrition(proteins: "6 г", fats: "6 г", carbs: "24 г"),
        fixedSizes: [SizePicker(volume: .medium, price: 229)],
        drinkTag: [.матча, .молочнаяПенка]
    )
    
    static let lemonade = Ponchi(
        productId: "lemonade",
        name: "Лимонад",
        category: .notCoffee,
        basePrice: 239,
        image: "Лимонад",
        description: "",
        calories: "150 ккал",
        nutrition: Nutrition(proteins: "0 г", fats: "0 г", carbs: "37 г"),
        fixedSizes: [SizePicker(volume: .medium, price: 239)],
        drinkTag: [.фруктовый, .освежающий, .холодный]
    )
    
    static let milkShake = Ponchi(
        productId: "milkshake",
        name: "Молочный коктейль",
        category: .notCoffee,
        basePrice: 159,
        image: "МолочныйКоктейль",
        description: "",
        calories: "280 ккал",
        nutrition: Nutrition(proteins: "8 г", fats: "10 г", carbs: "30 г"),
        fixedSizes: [SizePicker(volume: .medium, price: 159)],
        drinkTag: [.сладкий, .холодный, .ванильный]
    )
    
    static let teaInAssortment = Ponchi(
        productId: "teaInAssortment",
        name: "Чай в ассортименте",
        category: .notCoffee,
        basePrice: 199,
        image: "эрлГрей",
        description: "Все чаи несладкие, завариваются с помощью фильтр-пакета, выберите понравившийся",
        calories: "5 ккал",
        nutrition: Nutrition(proteins: "0 г", fats: "0 г", carbs: "1 г"),
        fixedSizes: [
            SizePicker(volume: .small, price: 169),
            SizePicker(volume: .medium, price: 199)
        ],
        drinkTag: [.лёгкий, .травяной, .тёплый],
        teaType: TeaType.allCases,
        selectedTeaType: .earlGrey
    )
    
    // Еда
    static let sendwichWithHam = Ponchi(
        productId: "sendwichWithHam",
        name: "Сэндвич с ветчиной",
        category: .food,
        basePrice: 320,
        image: "СендвичВетченаТарелка",
        description: "",
        calories: "280 ккал",
        weight: "180 г",
        nutrition: Nutrition(proteins: "15 г", fats: "12 г", carbs: "30 г"),
        foodTag: [.хрустящая, .наЗавтрак]
    )

    static let sendwichWithSelmon = Ponchi(
        productId: "sendwichWithSelmon",
        name: "Сэндвич с лососем",
        category: .food,
        basePrice: 359,
        image: "",
        description: "",
        calories: "320 ккал",
        weight: "180 г",
        nutrition: Nutrition(proteins: "18 г", fats: "10 г", carbs: "28 г"),
        foodTag: [.вегетарианская, .сытная]
    )

    static let sendwichWithAvocado = Ponchi(
        productId: "sendwichWithAvocado",
        name: "Сэндвич с лососем",
        category: .food,
        basePrice: 369,
        image: "ЛососьНаТарелке",
        description: "",
        calories: "350 ккал",
        weight: "200 г",
        nutrition: Nutrition(proteins: "17 г", fats: "15 г", carbs: "30 г"),
        foodTag: [.вегетарианская, .наЗавтрак]
    )

    static let vienneseWaffle = Ponchi(
        productId: "vienneseWaffle",
        name: "Венская вафля",
        category: .food,
        basePrice: 119,
        image: "банановаяВафля",
        description: "",
        calories: "250 ккал",
        weight: "120 г",
        nutrition: Nutrition(proteins: "5 г", fats: "12 г", carbs: "28 г"),
        foodTag: [.вегетарианская, .хрустящая]
    )

    static let syrniki = Ponchi(
        productId: "syrniki",
        name: "Сырники",
        category: .food,
        basePrice: 259,
        image: "Сырники2Клубника",
        images: ["Сырники2Клубника", "Сырники3Сметана"],
        description: "",
        calories: "280 ккал",
        weight: "150 г",
        nutrition: Nutrition(proteins: "8 г", fats: "10 г", carbs: "32 г"),
        fixedSizes: [
            SizePicker(volume: .small, price: 189),
            SizePicker(volume: .medium, price: 259)
        ],
        foodTag: [.сырная, .наЗавтрак]
    )

    static let muesly = Ponchi(
        productId: "muesly",
        name: "Мультизлаковые мюсли",
        category: .food,
        basePrice: 149,
        image: "Мюсли",
        description: "",
        calories: "200 ккал",
        weight: "100 г",
        nutrition: Nutrition(proteins: "6 г", fats: "5 г", carbs: "35 г"),
        foodTag: [.наЗавтрак, .тёплая]
    )

    static let pancakes = Ponchi(
        productId: "pancakes",
        name: "Оладьи",
        category: .food,
        basePrice: 109,
        image: "Панкейки3Кленовый",
        description: "",
        calories: "220 ккал",
        weight: "120 г",
        nutrition: Nutrition(proteins: "5 г", fats: "6 г", carbs: "35 г"),
        foodTag: [.сладкая, .классика]
    )
    
}

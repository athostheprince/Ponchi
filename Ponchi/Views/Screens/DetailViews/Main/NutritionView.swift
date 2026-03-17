//
//  NutritionView.swift
//  Ponchi
//
//  Created by mary romanova on 07.12.2025.
//

import SwiftUI

struct NutritionView: View {
    let nutrition: Nutrition
    let calories: String
    
    // Преобразуем Nutrition в массив для динамического отображения
    var nutritionItems: [(title: String, value: String)] {
        [
            ("Белки", nutrition.proteins),
            ("Жиры", nutrition.fats),
            ("Углеводы", nutrition.carbs)
        ]
    }
    
    var body: some View {
        VStack(spacing: 5) {
            Text(calories)
                .font(.uncage(20))
                .foregroundColor(.brightGreen)
            
            HStack(spacing: 20) {
                ForEach(nutritionItems, id: \.title) { item in
                    VStack {
                        Text(item.title)
                            .font(.uncage(12))
                            .foregroundColor(.brightGreen)
                        Text(item.value)
                            .font(.uncage(15))
                            .foregroundColor(.brightGreen)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .padding(8)
            .overlay {
                Capsule()
                    .stroke(Color.peony, lineWidth: 2)
            }
            .padding(5)
        }
    }
}

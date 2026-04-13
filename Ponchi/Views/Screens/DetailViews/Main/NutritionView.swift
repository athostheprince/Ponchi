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
        VStack(spacing: 10) {
            Text(calories)
                .font(.uncage(20))
                .foregroundColor(.brightGreen)
                .padding(.horizontal, 14)
                .padding(.vertical, 6)
                .background(Color.peony.opacity(0.55))
                .clipShape(Capsule())
            
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
            .padding(.horizontal, 10)
            .padding(.vertical, 12)
            .background(Color.cream.opacity(0.96))
            .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .stroke(Color.softStroke, lineWidth: 1)
            }
        }
        .padding(.top, 4)
    }
}

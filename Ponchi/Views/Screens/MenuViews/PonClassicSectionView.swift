//
//  PonchiSectionView.swift
//  Ponchi
//
//  Created by mary romanova on 25.11.2024.
//

import SwiftUI

struct PonClassicSectionView: View {
    var product: Ponchi
    @State var isTapped = false

    var body: some View {
        ZStack {
            VStack(spacing: 3) {
                
                // Изображение
                Image(product.image)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 135) // ограничиваем
                    .cornerRadius(20)

                // Название
                Text(product.name.uppercased())
                    .font(.caption)
                    .fontWeight(.semibold)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .minimumScaleFactor(0.7)
                    .frame(height: 36) // чтобы не прыгало

                // Теги
                VStack(spacing: 4) {
                    ForEach(getTagRows(), id: \.self) { row in
                        HStack(spacing: 4) {
                            ForEach(row, id: \.title) { tag in
                                TagBadge(title: tag.title, icon: tag.icon, color: tag.color)
                            }
                        }
                    }
                }
                .frame(height: 40) // ограничиваем высоту блока тегов
                
                //Spacer()
            }
            .padding(8)
            .frame(width: 180, height: 250) // фиксированная карточка
            .background(Color.white)
            .cornerRadius(20)
            .shadow(radius: 5)
        }
    }

    // максимум 4 тега, по 2 в строке
    func getTagRows() -> [[TagData]] {
        let tags = product.drinkTag?.map {
            TagData(title: $0.rawValue, icon: $0.icon, color: $0.color)
        } ?? product.foodTag?.map {
            TagData(title: $0.rawValue, icon: $0.icon, color: $0.color)
        } ?? []

        let limited = Array(tags.prefix(4))
        return stride(from: 0, to: limited.count, by: 2).map {
            Array(limited[$0..<min($0 + 2, limited.count)])
        }
    }
}


struct TagData: Hashable {
    let title: String
    let icon: String
    let color: Color
}


struct TagBadge: View {
    let title: String
    let icon: String
    let color: Color

    var body: some View {
        Text(title)
            .font(.caption2)
            .bold()
            .lineLimit(1)
            .minimumScaleFactor(0.5)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(color)
            .foregroundColor(.white)
            .cornerRadius(12)
    }
}



#Preview {
    PonClassicSectionView(product: MockPonchiData.cappuccino)
}

// Text(String(format: "%.2f ₽", item.price))

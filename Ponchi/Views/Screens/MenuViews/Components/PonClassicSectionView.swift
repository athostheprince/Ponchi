//
//  PonchiSectionView.swift
//  Ponchi
//
//  Created by mary romanova on 25.11.2024.
//

import SwiftUI

struct PonClassicSectionView: View {
    var ponchi: Ponchi
    @State var isTapped = false
    var hasMultipleSize: Bool

    var body: some View {
        VStack(spacing: 0) {
            
            Image(ponchi.image)
                .resizable()
                .scaledToFill()
                .frame(height: 260 * 0.6) // 60%
                .frame(maxWidth: .infinity)
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .clipped()
                .overlay(alignment: .topTrailing) {
                    PriceView(price: ponchi.basePrice, hasMultipleSize: hasMultipleSize)
                }
            
            VStack(spacing: 6) {
                
                Text(ponchi.name.uppercased())
                    .font(.lepca(20))
                    .fontWeight(.semibold)
                    .foregroundStyle(Color.peony)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .minimumScaleFactor(0.7)
                    .frame(height: 36)
                
                VStack(spacing: 4) {
                    ForEach(getTagRows(), id: \.self) { row in
                        HStack(spacing: 4) {
                            ForEach(row, id: \.title) { tag in
                                TagBadge(title: tag.title, icon: tag.icon, color: tag.color)
                            }
                        }
                    }
                }
                .frame(height: 40)
            }
            .padding(8)
            .frame(height: 260 * 0.4)
        }
        .frame(width: 180, height: 260)
        .background(Color.brightGreen)
        .cornerRadius(20)
    }

    func getTagRows() -> [[TagData]] {
        let tags = ponchi.drinkTag?.map {
            TagData(title: $0.rawValue, icon: $0.icon, color: $0.color)
        } ?? ponchi.foodTag?.map {
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
            .foregroundColor(.brightGreen)
            .cornerRadius(12)
    }
}

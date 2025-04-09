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
        VStack(alignment: .trailing) {
            ZStack(alignment: .bottom) {
                Image(product.image)
                    .resizable()
                    .scaledToFit()
                    .cornerRadius(10)
                
                Text(product.name)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(.white)
                    .shadow(radius: 3)
            }
            .padding()
            .background(Color.white)
            .cornerRadius(10)
            .shadow(radius: 10)
        }
        
    }
}

#Preview {
    PonClassicSectionView(product: MockPonchiData.cappuccino)
}

// Text(String(format: "%.2f ₽", item.price))

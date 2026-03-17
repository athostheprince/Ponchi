//
//  PriceView.swift
//  Ponchi
//
//  Created by mary romanova on 08.12.2025.
//

import SwiftUI

struct PriceView: View {
    
    let price: Int
    let hasMultipleSize: Bool
    
    var body: some View {
        ZStack {
            Capsule()
                .frame(width: 65, height: 20)
                .foregroundStyle(Color.brightGreen)
            Text(hasMultipleSize ? "от \(price)₽" : "\(price)₽")
                .font(hasMultipleSize ? .lepca(12) : .lepca(14))
                .foregroundStyle(Color.peony)
                .padding(10)
                .shadow(radius: 5)
       
            Capsule()
                .stroke(lineWidth: 2)
                .foregroundColor(Color.matcha)
                .frame(width: 65, height: 20)
        }
        .padding(.horizontal, 5)
    }
}

#Preview {
    PriceView(price: 120, hasMultipleSize: true)
}

//
//  TotalPriceButton.swift
//  Ponchi
//
//  Created by mary romanova on 07.12.2025.
//

import SwiftUI

struct TotalPriceButton: View {
    
    @EnvironmentObject var ponchiViewModel: PonchiViewModel
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 30)
                .frame(width: 200, height: 50)
                .foregroundStyle(Color.brightGreen)
            HStack(spacing: 5) {
                Text("₽")
                    .font(.title)
                    .bold()
                    .foregroundStyle(Color.peony)
                
                HStack(spacing: 0) {
                    ForEach(ponchiViewModel.animatedPrice.indices, id: \.self) { index in
                        RotatingDigitView(currentDigit: ponchiViewModel.animatedPrice[index], color: Color.peony)
                    }
                }
                .font(.title3)
                .monospacedDigit()
                .foregroundStyle(.white)
                .padding(.horizontal, 5)
            }
        }
    }
}

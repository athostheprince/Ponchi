//
//  TotalPriceButton.swift
//  Ponchi
//
//  Created by mary romanova on 18.09.2025.
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
                    .foregroundStyle(.white)
                
                HStack(spacing: 0) {
                    ForEach(ponchiViewModel.animatedPrice.indices, id: \.self) { index in
                        RotatingDigitView(currentDigit: ponchiViewModel.animatedPrice[index], color: Color.brightGreen)
                    }
                }
                .font(.custom("Kica-PERSONALUSE-Light", fixedSize: 15))
                .monospacedDigit()
                .foregroundStyle(.white)
                .padding(.horizontal, 5)
            }
        }
    }
}

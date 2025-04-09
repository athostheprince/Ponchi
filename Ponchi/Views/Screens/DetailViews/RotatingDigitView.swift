//
//  RotatingDigitView.swift
//  Ponchi
//
//  Created by mary romanova on 13.03.2025.
//

import SwiftUI

struct RotatingDigitView: View {
    
    let currentDigit: Int
    
    var body: some View {
        ZStack {
            ForEach(0..<10, id: \.self) { digit in
                Text("\(digit)")
                    .fontWeight(.bold)
                    .font(.title)
                    .foregroundColor(.white)
                    .opacity(digit == currentDigit ? 1 : 0)
                    .offset(y: CGFloat(digit - currentDigit) * 30)
                    .animation(.easeInOut(duration: 0.3), value: currentDigit)
            }
        }
        .frame(height: 30)
        .clipped()
    }
}

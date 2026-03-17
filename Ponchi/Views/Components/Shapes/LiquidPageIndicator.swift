//
//  LiquidPageIndicator.swift
//  Ponchi
//
//  Created by mary romanova on 05.12.2025.
//

import SwiftUI

struct LiquidPageIndicator: View {
    
    let pages: Int
    let current: Int
    
    var body: some View {
        HStack {
            ForEach(0..<pages, id: \.self) { index in
                Capsule()
                    .fill(.ultraThinMaterial)
                    //.fill(Color.white)
                    .frame(
                        width: current == index ? 30 : (abs(current - index) == 1 ? 14 : 8),
                        height: 8
                    )
                    .animation(.spring(response: 0.35, dampingFraction: 0.65), value: current)
            }
        }
    }
}

#Preview {
    LiquidPageIndicator(pages: 3, current: 1)
}

//
//  IncreaseButton.swift
//  Ponchi
//
//  Created by mary romanova on 13.09.2025.
//

import SwiftUI

struct IncreaseButton: View {
    var quantity: Int
    var onIncrease: () -> Void
    var onDecrease: () -> Void
    
    var body: some View {
        HStack(spacing: 20) {
            Button {
                onDecrease()
            } label: {
                Image(systemName: "minus")
                    
            }

            Text("\(quantity)")
              

            Button {
                onIncrease()
            } label: {
                Image(systemName: "plus")
                    
            }
        }
        .foregroundStyle(Color.brightGreen)
        .padding(5)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.peony)
        )
        .overlay {
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.brightPeony, lineWidth: 1)
        }
    }
}

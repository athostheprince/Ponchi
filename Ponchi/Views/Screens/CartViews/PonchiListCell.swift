//
//  PonchiListCell.swift
//  Ponchi
//
//  Created by mary romanova on 23.01.2025.
//

import SwiftUI

struct PonchiListCell: View {
    
    @Binding var ponchi: Ponchi
    @EnvironmentObject var order: Cart
    
    var body: some View {
        HStack {
            Image(ponchi.image)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 44, height: 44)
                .cornerRadius(10)
            
            VStack(alignment: .leading) {
                Text(ponchi.name)
                    .font(.title2)
                    .fontWeight(.medium)
                Text("₽\(ponchi.totalPrice)")
                    .foregroundStyle(.secondary)
                    .fontWeight(.semibold)
            }
            .padding()
            
            Spacer()
            
            Stepper(value: $ponchi.quantity, in: 1...99) {
                Text("\(ponchi.quantity)")
            }
            .frame(width: 120)
        }
    }
}


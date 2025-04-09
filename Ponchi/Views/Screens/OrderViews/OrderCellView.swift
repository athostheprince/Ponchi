//
//  OnGoingOrdersVIew.swift
//  Ponchi
//
//  Created by mary romanova on 02.02.2025.
//

import SwiftUI

struct OrderCellView: View {
    
    let order: Order
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                
                Text("\(order.date.formatted(date: .numeric, time: .shortened))")
                    .font(.title3)
                    .foregroundStyle(.secondary)
                
                HStack {
                    
                    Image("coffeeToGo")
                        .renderingMode(.template)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 32, height: 32)
                        .foregroundStyle(.secondary)
                    
                    VStack(alignment: .leading) {
                        
                        ForEach(order.items) { order in
                            Text("\(order.name) X \(order.quantity)")
                                .font(.subheadline)
                        }
                    }
                }
            }
            .padding()
            
            Spacer()
            
            VStack {
                
                Text("\(order.totalPrice)")
                    .font(.title2)
                    .foregroundStyle(.secondary)
                
            }
            .padding(.horizontal)
        }
    }
}



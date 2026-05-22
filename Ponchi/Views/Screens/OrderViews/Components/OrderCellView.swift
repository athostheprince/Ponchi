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
        VStack(spacing: 10) {
            // Дата
            Text(order.date.formatted(date: .numeric, time: .shortened))
                .font(.subheadline)
                .foregroundStyle(.secondary)
            
            // Карточка заказа
            HStack {
                // Иконка + список товаров
                Image("coffeeToGo")
                    .renderingMode(.template)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 32, height: 32)
                    .foregroundStyle(.secondary)
                
                VStack(alignment: .leading, spacing: 4) {
                    ForEach(order.items) { item in
                        Text(item.displayName)
                            .font(.subheadline)
                            .bold()
                            .foregroundStyle(Color.brightGreen)
                    }
                }
                
                Spacer()
                
                // Цена
                Text("\(order.totalPrice) ₽")
                    .font(.custom("Kica-PERSONALUSE-Light", size: 16))
                    .bold()
                    .foregroundStyle(Color.brightGreen)
            }
            .padding()
            .background(Color.white)
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.peony, lineWidth: 2)
            )
            .padding(.horizontal)
            
            HStack {
                
                Text("\(order.status.rawValue)")
                    .font(.custom("Kica-PERSONALUSE-Light", size: 12))
                    .foregroundStyle(Color.brightGreen)
                Circle()
                    .frame(width: 8, height: 8)
                    .foregroundStyle(order.status == .pending ? Color.brightGreen : Color.gray)
                
                Spacer()
                
                // Кнопка "Повторить заказ"
                Button {
                    HapticManager.tap()
                    // Действие
                } label: {
                    ZStack {
                        Circle()
                            .stroke(Color.peony, lineWidth: 2)
                            .frame(width: 40, height: 40)
                        
                        Image(systemName: "arrow.trianglehead.clockwise")
                            .resizable()
                            .scaledToFit()
                            .foregroundStyle(Color.brightGreen)
                            .frame(width: 20, height: 20)
                    }
                }
            }
            .padding(.horizontal)
            
            // Разделитель между заказами
            Rectangle()
                .frame(height: 1.5)
                .foregroundColor(Color.gray.opacity(0.3))
                .padding(.horizontal)
        }
        .padding(.vertical, 8)
    }
}

private struct OrderCellPreview: View {
    private let mockOrder = Order(
        items: [
            MockPonchiData.americano,
            MockPonchiData.cappuccino
        ],
        status: .preparing
    )
    
    var body: some View {
        OrderCellView(order: mockOrder)
    }
}

#Preview {
    OrderCellPreview()
}

//
//  PonchiChequeView.swift
//  Ponchi
//
//  Created by mary romanova on 24.11.2024.
//

import SwiftUI

struct PonchiChequeView: View {
    
    @EnvironmentObject var order: OrderViewModel
    @State private var selected = 0
    
    var body: some View {
        NavigationStack {
            VStack {
                HStack {
                    Button(action: {
                        withAnimation(.easeInOut) {
                            selected = 0
                        }
                    }) {
                        Text("В работе")
                            .font(.title2)
                            .bold()
                            .foregroundStyle(selected == 0 ? Color("brandColor") : .secondary)
                            .frame(maxWidth: .infinity)
                    }
                    
                    Button(action: {
                        withAnimation(.easeInOut) {
                            selected = 1
                        }
                    }) {
                        Text("Завершенные")
                            .font(.title2)
                            .bold()
                            .foregroundStyle(selected == 1 ? Color("brandColor") : .secondary)
                            .frame(maxWidth: .infinity)
                    }
                }
                .padding(.top, 10)
                
                // Подчеркивание
                GeometryReader { proxy in
                    Rectangle()
                        .frame(width: proxy.size.width / 2, height: 3)
                        .foregroundColor(Color("brandColor"))
                        .offset(x: selected == 0 ? 0 : proxy.size.width / 2)
                        .animation(.easeInOut, value: selected)
                }
                .frame(height: 3)
                
                ScrollView {
                    VStack(spacing: 10) {
                        if selected == 0 {
                            ForEach(order.activeOrders) { order in
                                OrderCellView(order: order)
                            }
                        } else {
                            ForEach(order.completedOrders) { order in
                                OrderCellView(order: order)
                            }
                        }
                    }
                    .padding(.top, 10)
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle("🧾 Заказы")
        }
    }
}

#Preview {
    PonchiCustomTabBar()
        .environmentObject(OrderViewModel())
        .environmentObject(Cart())
        .environmentObject(PonchiViewModel())
}

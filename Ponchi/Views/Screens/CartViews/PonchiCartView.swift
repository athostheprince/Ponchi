//
//  CartView.swift
//  Ponchi
//
//  Created by mary romanova on 23.11.2024.
//

import SwiftUI

struct PonchiCartView: View {
    
    @EnvironmentObject var cart: Cart
    @EnvironmentObject var order: OrderViewModel
    
    var body: some View {
        NavigationStack {
            ZStack {
                VStack(alignment: .trailing) {
                    
                    List {
                        ForEach($cart.items) { $item in
                            HStack {
                                PonchiListCell(ponchi: $item)
                                
                                    .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                        Button(role: .destructive) {
                                            cart.deleteItems(item)
                                        } label: {
                                            Image(systemName: "trash.fill")
                                        }
                                    }
                            }
                        }
                    }

                    
                    if !cart.items.isEmpty {
                        
                        HStack {
                            
                            VStack(alignment: .center) {
                                Text("Итого: ")
                                    .font(.title3)
                                    .foregroundStyle(.secondary)
                                
                                Text("₽\(cart.total)")
                                    .font(.title2)
                                    .bold()
                            }
                            
                            Spacer()
                            
                            Button {
                                order.placeOrder(from: cart)
                                cart.clearCart()
                            } label: {
                                Text("Оплатить")
                                    .foregroundStyle(.white)
                                    .padding()
                                    .background(Color("brandColor"))
                                    .cornerRadius(10)
                            }
                                .frame(height: 60)
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .padding(.bottom, 60)
                        .frame(width: UIScreen.main.bounds.width / 1.7)
                    }
                }
                
                if cart.items.isEmpty {
                    EmptyOrderView(imageName: "emptyOrder", message: "Вы еще ничего не выбрали!")
                }
            }
            .navigationTitle("☕️ Заказ")
        }
    }
}

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
    @EnvironmentObject var ponchi: PonchiViewModel
    
    @State private var confirmClear = false
    @State private var showMap = false
    
    var body: some View {
        VStack {
           
                Text("КОРЗИНА")
                    .font(.lepca(40))
                    .foregroundStyle(!cart.items.isEmpty ? Color.peony : Color.brightGreen)
                    .padding(8)
                
            if !cart.items.isEmpty {
                ZStack {
                    Rectangle()
                        .frame(height: 1)
                        .foregroundStyle(Color.peony)
                    
                    Text("время приготовления: ~5 мин")
                        .font(.caviarb(15))
                        .padding(.horizontal, 5)
                        .foregroundStyle(Color.peony)
                        .background(Color.brightGreen)
                    
                }
                .padding(20)
            }
            
            ZStack {
                VStack {
                    
                    if !cart.items.isEmpty {
                        
                        ScrollView {
                            ForEach(cart.items) { item in
                                
                                ListCellView(image: item.image, name: item.name, price: item.totalPrice, quantity: item.quantity, toppings: item.selectedToppings.isEmpty ? "без добавок" : item.selectedToppingsDescription, size: item.hasMultipleSizes ? item.size?.rawValue ?? "" : "", increaseAction: {
                                    cart.addItem(item)
                                    
                                }, decreaseAction: {
                                    withAnimation {
                                        cart.removeItem(item)
                                        guard item.quantity > 1 else { return }
                                    }
                                    
                                })
                            }
                        }
                                                        
                            Button {
                                HapticManager.heavyTab()
                                order.placeOrder(from: cart)
                                cart.clearCart()
                            } label: {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 30)
                                        .frame(width: 200, height: 50)
                                        .foregroundStyle(Color.peony)
                                    HStack(spacing: 5) {
                                        Text("₽")
                                            .font(.title)
                                            .bold()
                                            .foregroundStyle(Color.brightGreen)
                                        
                                        HStack(spacing: 0) {
                                            ForEach(cart.animatedPrice.indices, id: \.self) { index in
                                                RotatingDigitView(currentDigit: cart.animatedPrice[index], color: Color.brightGreen)
                                            }
                                        }
                                        .font(.title3)
                                        .monospacedDigit()
                                        .foregroundStyle(Color.peony)
                                        .padding(.horizontal, 5)
                                    }
                                }
                                .overlay {
                                    RoundedRectangle(cornerRadius: 30)
                                        .stroke(Color.brightPeony, lineWidth: 2)
                                        .frame(width: 200, height: 50)
                                       
                                }
                            }
                            .offset(y: -80)
                        
                    }
                }
                
                if cart.items.isEmpty {
                    EmptyOrderView(imageName: "emptyOrder", message: "Самое время что-нибудь выбрать!", action: { ponchi.selectedTab(0) } )
                }
            }
        }
        
        .overlay(alignment: .topLeading) {
            if !cart.items.isEmpty {
                if confirmClear {
                    Button {
                        HapticManager.heavyTab()
                        cart.items.removeAll()
                        confirmClear.toggle()
                    } label: {
                        Text("ОЧИСТИТЬ")
                            .font(.caviarb(13))
                            .foregroundStyle(Color.brightGreen)
                            .padding(8)
                            .background(Color.peony)
                            .cornerRadius(20)
                            .padding()
                            .offset(y: -8)
                    }
                    .transition(.scale.combined(with: .opacity))
                    
                    
                } else {
                    
                    Button {
                        HapticManager.tap()
                        withAnimation {
                            confirmClear.toggle()
                        }
                    } label: {
                        
                        Image(systemName: "trash.fill")
                            .resizable()
                            .scaledToFit()
                            .symbolRenderingMode(.palette)
                            .foregroundStyle(Color.peony)
                            .frame(width: 30, height: 30)
                            .padding()
                            .offset(y: -8)
                        
                    }
                    .transition(.scale.combined(with: .opacity))
                }
            }
        }
        
        .overlay(alignment: .topTrailing) {
            Button {
                showMap.toggle()
            } label: {
                Image("меткаКарты")
                    .resizable()
                    .scaledToFit()
                    .foregroundStyle(Color.peony)
                    .frame(width: 40, height: 40)
                    .padding()
                    .offset(y: -8)
            }
        }
        
        .onAppear {
            cart.animatePriceChange(to: cart.total)
        }
        .onChange(of: cart.total) { oldValue, newValue in
            HapticManager.tap()
            cart.animatePriceChange(to: newValue)
            
        }
        .overlay {
            if ponchi.isShowingDetails {
                PonchiDrinkDetailView()
                    .environmentObject(ponchi)
                    .environmentObject(cart)
            }
        }
        .background(!cart.items.isEmpty ? Color.brightGreen : Color.biege)
        .sheet(isPresented: $showMap) {
            YandexMapView(latitude: 59.960043, longitude: 30.481464)
        }
    }
}

private struct PonchiCartPreview: View {
    private let cart: Cart = {
        let cart = Cart()
        cart.items = [
            MockPonchiData.cappuccino,
            MockPonchiData.americano,
            MockPonchiData.latte
        ]
        return cart
    }()
    
    private let orderVM = OrderViewModel()
    private let ponchi = PreviewFactory.makePonchiViewModel()
    
    var body: some View {
        PonchiCartView()
            .environmentObject(cart)
            .environmentObject(orderVM)
            .environmentObject(ponchi)
    }
}

#Preview {
    PonchiCartPreview()
}

//                                    HapticManager.heavyTab()
//                                    withAnimation {
//                                        if let index = cart.items.firstIndex(where: { $0.id == item.id }) {
//                                            ponchi.selectedPonchi = cart.items[index]
//                                            ponchi.editedItemIndex = index
//                                            ponchi.isShowingDetails = true
//                                        }
//                                        ponchi.isShowingDetails = true
//                                    }

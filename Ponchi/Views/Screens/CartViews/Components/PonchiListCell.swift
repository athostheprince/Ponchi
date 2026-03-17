//
//  PonchiListCell.swift
//  Ponchi
//
//  Created by mary romanova on 23.01.2025.
//

import SwiftUI
    
struct ListCellView: View {
    
    //var ponchi: Ponchi
    //@EnvironmentObject var cart: Cart
    //@State private var quantity = 1
    @State private var animatedPrice = [Int]()
    //@EnvironmentObject var ponchiViewModel: PonchiViewModel
    
    var image: String
    var name: String
    var price: Int
    var quantity: Int
    //var comment: String
    var toppings: String
    var size: String
    
    var increaseAction: () -> Void
    var decreaseAction: () -> Void
    
    var body: some View {
        HStack {
            Image(image)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 100, height: 100)
                .cornerRadius(20)
            
            VStack(alignment: .leading) {
                
                    Text(name + " " + size)
                        .font(.caviarb(20))
                        .foregroundStyle(Color.brightGreen)
                
                    //.padding(.vertical, 3)
                
                Text(toppings)
                    .font(.caviarb(12))
                    .foregroundStyle(Color.brightGreen)
                    .padding(.vertical, 3)
                
                HStack {
                    IncreaseButton(
                        quantity: quantity,
                        onIncrease: {
//                            cart.addItem(ponchi)
//                            quantity += 1
                            increaseAction()
                        },
                        onDecrease: {
//                            cart.removeItem(ponchi)
//                            guard quantity > 1 else { return }
//                            quantity -= 1
                            decreaseAction()
                        }
                    )
                    
                    Spacer()
                    
//                    Text("\(cart.totalPrice(for: ponchi)) ₽")
                    Text("\(price) ₽")
                        .foregroundStyle(Color.brightGreen)
                        .font(.caviarb(15))
                }
            }
            .padding(.vertical, 7)
            .padding(.horizontal, 5)
            
            Spacer()
        }
        .padding(.horizontal, 7)
        .background(Color.peony)
        .cornerRadius(20)
        .padding(.horizontal, 7)
    }
}

#Preview {
    ListCellView(image: MockPonchiData.cappuccino.image, name: MockPonchiData.cappuccino.name, price: MockPonchiData.cappuccino.basePrice, quantity: MockPonchiData.cappuccino.quantity, toppings: "молоко: миндальное, сироп: ванильный, холодный", size: "M", increaseAction: {}, decreaseAction: {})
}

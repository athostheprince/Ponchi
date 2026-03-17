//
//  PonchiChequeView.swift
//  Ponchi
//
//  Created by mary romanova on 24.11.2024.
//

import SwiftUI

import SwiftUI

struct CapsuleSegmentView: View {
    let title: String
    let isSelected: Bool
    let namespace: Namespace.ID
    let onTap: () -> Void
    
    var body: some View {
        Text(title)
            .font(.custom("Kica-PERSONALUSE-Light", size: 16))
            .padding(.vertical, 8)
            .padding(.horizontal, 20)
            .background(
                ZStack {
                    if isSelected {
                        Capsule()
                            .stroke(Color.peony, lineWidth: 4)
                            .matchedGeometryEffect(id: "segment", in: namespace)
                    }
                }
            )
            .foregroundColor(isSelected ? Color.brightGreen : .secondary)
            .onTapGesture {
                HapticManager.scroll()
                onTap()
            }
    }
}

struct PonchiChequeView: View {
    @EnvironmentObject var order: OrderViewModel
    @State private var selected = 0
    @Namespace private var animation
    
    private let titles = ["В работе", "Завершенные"]
    
    var body: some View {
        //NavigationStack {
            VStack {
                
                Text("ЗАКАЗЫ")
                    .font(.custom("Kica-PERSONALUSE-Light", fixedSize: 25))
                    .foregroundStyle(Color.brightGreen)
                // MARK: - Сегменты
                HStack {
                    
                    ForEach(titles.indices, id: \.self) { index in
                        CapsuleSegmentView(
                            title: titles[index],
                            isSelected: selected == index,
                            namespace: animation
                        ) {
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                                selected = index
                            }
                        }
                    }
                }
                .padding(.top, 10)
                
                // MARK: - Контент
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
                
                //Spacer()
            }
            .padding()
           // .navigationTitle("🧾 Заказы")
        //}
    }
}




#Preview {
    PonchiChequeView()
        .environmentObject(OrderViewModel())
}


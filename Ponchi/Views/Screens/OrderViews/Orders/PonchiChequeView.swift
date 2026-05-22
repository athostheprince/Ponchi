//
//  PonchiChequeView.swift
//  Ponchi
//
//  Created by mary romanova on 24.11.2024.
//

import SwiftUI

struct CapsuleSegmentView: View {
    let title: String
    let isSelected: Bool
    let namespace: Namespace.ID
    let onTap: () -> Void
    
    var body: some View {
        Text(title)
            .font(.caviarb(16))
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
    
    private let titles = ["В работе", "Завершены"]
    private var visibleOrders: [Order] {
        selected == 0 ? order.activeOrders : order.completedOrders
    }
    
    var body: some View {
        //NavigationStack {
        ZStack {
            Color.biege
                .ignoresSafeArea()

            VStack {
                
                Text("ЗАКАЗЫ")
                    .font(.lepca(40))
                    .foregroundStyle(Color.brightGreen)
                    .padding(8)
                    .frame(maxWidth: .infinity, alignment: .center)
                // MARK: - Сегменты
                HStack(spacing: 34) {
                    
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
                        if visibleOrders.isEmpty {
                            EmptyOrdersStateView()
                                .padding(.top, 58)
                        } else {
                            ForEach(visibleOrders) { order in
                                OrderCellView(order: order)
                            }
                        }
                    }
                    .padding(.top, 10)
                }
                
                //Spacer()
            }
            .padding()
        }
           // .navigationTitle("🧾 Заказы")
        //}
    }
}

private struct EmptyOrdersStateView: View {
    var body: some View {
        VStack(spacing: 14) {
            Image("emptyOrdersRaccoon")
                .resizable()
                .scaledToFit()
                .frame(maxWidth: 310)

            Text("Заказов пока нет")
                .font(.caviarb(18))
                .foregroundStyle(Color.brightGreen.opacity(0.72))
        }
        .frame(maxWidth: .infinity)
    }
}




#Preview {
    PonchiChequeView()
        .environmentObject(OrderViewModel())
}

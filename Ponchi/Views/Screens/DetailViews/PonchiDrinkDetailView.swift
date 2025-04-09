//
//  PonchiDetail.swift
//  Ponchi
//
//  Created by mary romanova on 04.12.2024.
//

import SwiftUI

struct PonchiDrinkDetailView: View {
    @EnvironmentObject var ponchiViewModel: PonchiViewModel
    @EnvironmentObject var order: Cart
    @State var isLiked = false

    var body: some View {
        ZStack(alignment: .bottom) {
            VStack(spacing: 0) {
                ZStack(alignment: .top) {
                    if let ponchi = ponchiViewModel.selectedPonchi {
                        Image(ponchi.image)
                            .resizable()
                            .scaledToFill()
                        
                        if ponchiViewModel.selectedPonchi?.size != .noSize && ponchiViewModel.selectedPonchi?.fixedSizes?.count ?? 0 > 1 {
                            CustomSegmentPicker(
                                categories: ponchiViewModel.sizes
                            )
                            .padding()
                        }
                    }
                }
                VStack {
                   
                        VStack {
                            if let ponchi = ponchiViewModel.selectedPonchi {
                                HStack {
                                    VStack {
                                        Text(ponchi.ml)
                                            .font(.title2)
                                            .foregroundStyle(.secondary)
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                        
                                        Text(ponchi.name)
                                            .font(.title)
                                            .bold()
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                    }
                                    .padding(10)
                                    
                                    Spacer()
                                    
                                    ZStack {
                                        Circle()
                                            //.stroke(Color("brandColor"), lineWidth: 2)
                                            .frame(height: 55)
                                            .foregroundStyle(Color("brandColor").opacity(0.4))
                                    
                                    Button {
                                        isLiked.toggle()
                                    } label: {
                                            Image(systemName: "heart.fill")
                                                .resizable()
                                                .scaledToFit()
                                                .frame(height: 27)
                                                .foregroundStyle(isLiked ? Color.pink : Color.white)
                                                
                                        }
                                    }
                                    .padding(10)
                                }
                                
                                if ponchi.hasTopping {
                                    PonchiToppingsView()
                                        .environmentObject(ponchiViewModel)
                                        .padding()
                                }
                                ScrollView {
                                    Text(ponchi.description)
                                        .lineLimit(nil)
                                        .padding()
                                        .font(.footnote)
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }
                        .background(Color.white)
                        .clipShape(RoundedCornersShape(corners: [.topLeft, .topRight], radius: 20))
                        .offset(y: -15)
                    
                    
                    
                    HStack {
            
                        Button {
                            ponchiViewModel.addToOrder(order: order)
                            ponchiViewModel.isShowingDetails.toggle()
                        } label: {
                            ZStack {
                                RoundedRectangle(cornerRadius: 30)
                                    .frame(width: 200, height: 50)
                                    .foregroundStyle(Color("brandColor"))
                                HStack(spacing: 5) {
                                    Text("₽")
                                        .font(.title)
                                        .bold()
                                        .foregroundStyle(.white)
                                    
                                    HStack(spacing: 0) {
                                        ForEach(ponchiViewModel.animatedPrice.indices, id: \.self) { index in
                                            RotatingDigitView(currentDigit: ponchiViewModel.animatedPrice[index])
                                        }
                                    }
                                    .font(.title3)
                                    .monospacedDigit()
                                    .foregroundStyle(.white)
                                    .padding(.horizontal, 5)
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 40)
                }
//                .background(Color.white)
//                .clipShape(RoundedCornersShape(corners: [.topLeft, .topRight], radius: 20))
//                .offset(y: -30)
            }
            .onAppear {
                if ponchiViewModel.selectedPonchi == nil {
                    ponchiViewModel.selectedPonchi = ponchiViewModel.ponchis.first
                }
            }
            .onChange(of: ponchiViewModel.selectedPonchi!.totalPrice) { oldValue, newValue in
                ponchiViewModel.animatePriceChange(to: newValue)
            }
            .overlay(
                CloseButton {
                    withAnimation {
                        ponchiViewModel.isShowingDetails = false
                    }
                }, alignment: .topTrailing
            )
        }
    }
}

struct RoundedCornersShape: Shape {
    var corners: UIRectCorner
    var radius: CGFloat
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}


#Preview {
    PonchiMenuView()
        .environmentObject(PonchiViewModel())
}


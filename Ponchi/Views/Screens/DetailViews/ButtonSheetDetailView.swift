//
//  ButtonSheetDetailView.swift
//  Ponchi
//
//  Created by mary romanova on 10.05.2025.
//

import SwiftUI

struct ButtonSheetDetailView: View {
    @EnvironmentObject var ponchiViewModel: PonchiViewModel
    @EnvironmentObject var order: Cart
    @State private var isLiked = false
    
    var ponchi: Ponchi
    
    var body: some View {
        VStack {
            VStack {
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
            .background(Color.white)
            .clipShape(RoundedCornersShape(corners: [.topLeft, .topRight], radius: 20))
            
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
    }
}

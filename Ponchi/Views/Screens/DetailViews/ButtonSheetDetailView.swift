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
        VStack(spacing: 0) {
            VStack(spacing: 16) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(ponchi.ml)
                            .font(.title2)
                            .foregroundStyle(.secondary)

                        Text(ponchi.name)
                            .font(.title)
                            .bold()
                    }

                    Spacer()

                    Button(action: {
                        isLiked.toggle()
                    }) {
                        Image(systemName: "heart.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 27, height: 27)
                            .foregroundStyle(isLiked ? Color.pink : Color.white)
                            .padding(12)
                            .background(
                                Circle()
                                    .fill(Color("brandColor").opacity(0.4))
                            )
                    }
                }
                .padding(.horizontal)

                if ponchi.hasTopping {
                    PonchiToppingsView()
                        .environmentObject(ponchiViewModel)
                        .padding(.horizontal)
                }

                ScrollView(showsIndicators: false) {
                    Text(ponchi.description)
                        .padding()
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .frame(maxHeight: 180) // Ограничим высоту
            }
            .background(Color.white)
            .clipShape(RoundedCornersShape(corners: [.topLeft, .topRight], radius: 20))

            Spacer(minLength: 16)

            Button(action: {
                ponchiViewModel.addToOrder(order: order)
            }) {
                ZStack {
                    RoundedRectangle(cornerRadius: 30)
                        .frame(height: 50)
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
            .padding(.horizontal, 40)
            .padding(.bottom, 20)
        }
        .background(Color.white)
        .ignoresSafeArea(edges: .bottom)
    }
}

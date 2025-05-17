//
//  PonchiDetail.swift
//  Ponchi
//
//  Created by mary romanova on 04.12.2024.
//

import SwiftUI
import BottomSheet

struct PonchiDrinkDetailView: View {
    @EnvironmentObject var ponchiViewModel: PonchiViewModel
    @EnvironmentObject var order: Cart
    @State var isLiked = false
    @State private var hasDragged: Bool = false
    @State private var selectedDetent: BottomSheet.PresentationDetent = .medium

    var body: some View {
        ZStack {
            Color.white
                .ignoresSafeArea()
            VStack(spacing: 0) {
                VStack(spacing: 0) {
                    
                    if let ponchi = ponchiViewModel.selectedPonchi {
                        
                        if ponchi.size != .noSize && (ponchi.fixedSizes?.count ?? 0) > 1 {
                            CustomSegmentPicker(
                                categories: ponchiViewModel.sizes
                            )
                        }
                        
                        Image(ponchi.image)
                            .resizable()
                            .scaledToFit()
                            .padding(.top, 20)
                        
                        Spacer()
                    }
                }

                .sheetPlus(isPresented: $ponchiViewModel.isPresented, background: Color.clear) {
                    ZStack(alignment: .top) {
                        Color.white
                            .clipShape(RoundedCornersShape(corners: [.topLeft, .topRight], radius: 20))
                            .ignoresSafeArea()
                        
                        VStack(spacing: 0) {
                            if let ponchi = ponchiViewModel.selectedPonchi {
                                // 📌 Закреплённый блок сверху
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
                                    ZStack {
                                        Circle()
                                            .frame(width: 50, height: 50)
                                            .foregroundStyle(Color("brandColor").opacity(0.4))
                                        Button {
                                            isLiked.toggle()
                                        } label: {
                                            Image(systemName: "heart.fill")
                                                .resizable()
                                                .scaledToFit()
                                                .frame(height: 24)
                                                .foregroundStyle(isLiked ? .pink : .white)
                                        }
                                    }
                                }
                                .padding(.horizontal)
                                .padding(.top, 10)

                                // 📌 Скроллящийся контент
                                ScrollView {
                                    VStack(spacing: 20) {
                                        if ponchi.hasTopping {
                                            PonchiToppingsView()
                                                .environmentObject(ponchiViewModel)
                                                .padding(.horizontal)
                                        }

                                        Text(ponchi.description)
                                            .font(.footnote)
                                            .foregroundStyle(.secondary)
                                            .padding(.horizontal)
                                    }
                                    .padding(.top)
                                    .padding(.bottom, 80)
                                }
                            }

                            Spacer()

                            // 📌 Кнопка снизу
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
                    .presentationDetentsPlus(
                        [.height(200), .fraction(0.4), .medium, .fraction(0.8)],
                        selection: $selectedDetent
                    )
                }
            }
            
        }
        .onAppear {
            if ponchiViewModel.selectedPonchi == nil {
                ponchiViewModel.selectedPonchi = ponchiViewModel.ponchis.first
            }
        }
        .onChange(of: ponchiViewModel.selectedPonchi?.totalPrice) { oldValue, newValue in
            if let newValue {
                ponchiViewModel.animatePriceChange(to: newValue)
            }
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

//
//  PonchiDetail.swift
//  Ponchi
//
//  Created by mary romanova on 04.12.2024.
//

import SwiftUI
import UIKit
//import BottomSheetSwiftUI

struct PonchiDrinkDetailView: View {
    @EnvironmentObject var ponchiViewModel: PonchiViewModel
    @EnvironmentObject var cart: Cart
    @EnvironmentObject var user: UserViewModel
    @State var bottomSheetPosition: BottomSheetPosition = .relative(0.53)
    
    @State private var showDetails = false
    
    @State private var selectedIndex: Int? = nil
    
    @State private var keyboard = KeyboardResponder()
    
    @Namespace var upsellNamespace
    
    @State private var currentImageIndex: Int = 0

    
    var body: some View {
        ZStack {
            
            Color.biege
                .ignoresSafeArea()
            VStack(spacing: 0) {
                VStack(spacing: 0) {
                    
                    if let ponchi = ponchiViewModel.selectedPonchi {
                        
                        ZStack(alignment: .top) {
                            if let images = ponchi.images, !images.isEmpty {
                                TabView(selection: $currentImageIndex) {
                                    ForEach(0..<images.count, id: \.self) { index in
                                        DetailImagesView(image: images[index], pages: images.count, current: currentImageIndex)
                                    }
                                }
                                .tabViewStyle(.page(indexDisplayMode: .never))
                            } else {
                                DetailImageView(image: ponchi.displayImge)
                            }
                            
                            if ponchi.hasMultipleSizes {
                                CustomSegmentPicker(
                                    categories: ponchiViewModel.sizes
                                )
                            }
                        }
                        
                        Spacer()
                    }
                }
                .bottomSheet(bottomSheetPosition: self.$bottomSheetPosition, switchablePositions: [
                    .relative(0.53),
                    .relativeTop(0.93)
                ]) {
                    
                    VStack {
                        if let ponchi = ponchiViewModel.selectedPonchi {
                            
                            VStack {
                                HStack {
                                    Text(ponchi.ml)
                                        .font(.caviarb(20))
                                        .foregroundStyle(.secondary)
                                    
                                    Spacer()
                                    
                                    HStack {
                                        Text("состав")
                                            .font(.caviarb(20))
                                        
                                        Image(systemName: showDetails ? "chevron.down" : "chevron.right")
                                    }
                                    .padding(5)
                                    .foregroundStyle(showDetails ? Color.brightGreen : Color.gray)
                                    .overlay{
                                        Capsule()
                                            .stroke(Color.secondary, lineWidth: 1)
                                    }
                                    .onTapGesture {
                                        withAnimation {
                                            showDetails.toggle()
                                        }
                                    }
                                }
                                .padding(.horizontal, 2)
                                .padding(.vertical, 10)
                                
                                if showDetails {
                                    if let nutrition = ponchi.nutrition {
                                        NutritionView(nutrition: nutrition, calories: ponchi.calories)
                                    }
                                }
                                Text(
                                    ponchi.selectedTeaType?.rawValue.uppercased() ?? ponchi.name.uppercased()
                                )
                                    .font(.lepca(35))
                                    .foregroundStyle(Color.brightGreen)
                                    .multilineTextAlignment(.center)
                                    .lineLimit(nil)
                                    .fixedSize(horizontal: false, vertical: true)
                                    .frame(maxWidth: .infinity, alignment: .center)
                                
                            }
                            .padding(.horizontal)
                            .padding(.top, 10)
                            .padding(5)
                            
                            VStack(spacing: 20) {
                                
                                if ponchiViewModel.hasTeaType,
                                   let teaTypes = ponchi.teaType {
                                    TeaChooseView(
                                        teaType: teaTypes,
                                        selectedTea: ponchiViewModel.selectedTeaBinding
                                    )
                                }
                                
                                if ponchi.hasTopping {
                                    PonchiToppingsView()
                                        .environmentObject(ponchiViewModel)
                                        .padding()
                                        .overlay {
                                            RoundedRectangle(cornerRadius: 20)
                                                .stroke(Color.peony, lineWidth: 2)
                                        }
                                        .padding(.horizontal)
                                }
                                
                                Text(ponchi.description)
                                    .font(.caviarb(15))
                                    .multilineTextAlignment(.center)
                                    .foregroundStyle(Color.brightGreen)
                                    .padding(.horizontal, 10)
                                
                                Comment(placeholder: "напишите, например, поменьше пенки...", text: $ponchiViewModel.comment)
                                
                            }
                            
                        }
                        
                        Spacer()
                        
                        Button {
                            HapticManager.heavyTab()
                            
                            ponchiViewModel.confirmAddOrder(for: cart)
                            
                            ponchiViewModel.isAddShown = true
                        } label: {
                            TotalPriceButton()
                                .padding()
                        }
                        
                    }
                    .padding(.bottom, keyboard.currentHeight + 16)
                    .animation(.easeInOut(duration: 0.25), value: keyboard.currentHeight)
                }
                .showDragIndicator(false)
                .customBackground(
                    Color.softPink
                        .cornerRadius(30)
                        .shadow(color: .white, radius: 10, x: 0, y: 0)
                )
                .bottomSheetSnap(position: $bottomSheetPosition, collapsed: .relative(0.53), expanded: .relativeTop(0.9))
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
            CloseButton(action: {
                HapticManager.tap()
                withAnimation {
                    ponchiViewModel.isShowingDetails = false
                    user.detailViewisExpanded = false
                    ponchiViewModel.isAddShown = false
                }
            }, color: Color.brightGreen)
            .scaleEffect(1)
            .padding(.horizontal, 5),
            alignment: .topTrailing
        )
        .overlay(alignment: .topLeading) {
            if let ponchi = ponchiViewModel.selectedPonchi {
                Button {
                    HapticManager.heavyTab()
                    user.toggleLiked(ponchi)
                    
                } label: {
                    LikeButtonView(isLiked: user.isLiked(ponchi))
                }
            }
        }
        .overlay {
            if ponchiViewModel.isAddShown {
                PonchiAddContainer(
                    items: ponchiViewModel.upsellItems,
                    selectedIndex: $selectedIndex,
                    cartAction: {
                        ponchiViewModel.isAddShown = false
                        ponchiViewModel.isShowingDetails = false
                    },
                    plusAction: { upsell in
                        cart.addUpsell(upsell)
                        ponchiViewModel.isAddShown = false
                        ponchiViewModel.isShowingDetails = false
                    },
                    closeAction: {
                        ponchiViewModel.isAddShown = false
                        ponchiViewModel.isShowingDetails = false
                    }
                )
                .zIndex(10)
                .transition(.opacity)
            }
        }
    }
}

#Preview {
    PonchiCustomTabBar()
        .environmentObject(PreviewFactory.makePonchiViewModel())
        .environmentObject(Cart())
        .environmentObject(UserViewModel())
}

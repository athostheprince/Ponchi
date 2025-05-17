//
//  MenuView.swift
//  Ponchi
//
//  Created by mary romanova on 23.11.2024.
//

import SwiftUI


struct PonchiMenuView: View {
    
    @EnvironmentObject var ponchiViewModel: PonchiViewModel
    
    var body: some View {
        ZStack {
            VStack {
               
                PonchiHeaderMenu()
                    .padding()
                
                PonCustomSegmentPicker(
                    categories: ponchiViewModel.newCategories,
                    selectedCategory: $ponchiViewModel.selectedCategory,
                    selectedIndex: $ponchiViewModel.selectedIndex
                )
                .padding(.vertical)
                
               
                PonchiMenuScrollView(selectedCategory: $ponchiViewModel.selectedCategory, selectedIndex: $ponchiViewModel.selectedIndex)
//                    .sheet(isPresented: $ponchiViewModel.isShowingDetails) {
//                        PonchiDrinkDetailView()
//                            .environmentObject(ponchiViewModel)
//                            .presentationDetents([.large])
//                    }
            }
            .blur(radius: ponchiViewModel.isShowingDetails ? 20 : 0)
           
//            if ponchiViewModel.isShowingDetails {
//                PonchiDrinkDetailView()
//                    .environmentObject(ponchiViewModel)
//            }
        }
      
        .overlay {
            if ponchiViewModel.isShowingDetails {
                PonchiDrinkDetailView()
            }
        }
        .onTapGesture {
            withAnimation {
                ponchiViewModel.isShownCups = false
            }
        }
        .animation(.easeInOut, value: ponchiViewModel.isShowingDetails)
        .sheet(isPresented: $ponchiViewModel.isSelected) {
            withAnimation {
                PonchiRegView()
                    .presentationDetents([.large, .fraction(0.8)])
                    .presentationCornerRadius(20)
            }
        }
    }
}

#Preview {
    PonchiCustomTabBar()
        .environmentObject(Cart())
        .environmentObject(PonchiViewModel())
}

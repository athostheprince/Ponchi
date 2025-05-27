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

                PonchiMenuScrollView(
                    selectedCategory: $ponchiViewModel.selectedCategory,
                    selectedIndex: $ponchiViewModel.selectedIndex
                )
            }
            .blur(radius: ponchiViewModel.isShowingDetails ? 20 : 0)

            if ponchiViewModel.isShowingDetails {
                Color.black.opacity(0.3)
                    .ignoresSafeArea()
                    .onTapGesture {
                        withAnimation {
                            ponchiViewModel.isShowingDetails = false
                        }
                    }
                PonchiDrinkDetailView()
            }
        }
        .onTapGesture {
            withAnimation {
                ponchiViewModel.isShownCups = false
            }
        }
    }
}




#Preview {
    PonchiCustomTabBar()
        .environmentObject(Cart())
        .environmentObject(PonchiViewModel())
}

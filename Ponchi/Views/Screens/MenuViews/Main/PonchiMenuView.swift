//
//  MenuView.swift
//  Ponchi
//
//  Created by mary romanova on 23.11.2024.
//

import SwiftUI

struct PonchiMenuView: View {
    @EnvironmentObject var ponchiViewModel: PonchiViewModel
    @EnvironmentObject var userViewModel: UserViewModel
    
    var body: some View {
        ZStack {
            Color.biege
                .ignoresSafeArea()

            VStack {
                PonchiHeaderMenu()
                    .padding(.horizontal, 10)
                
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
            .blur(radius: ponchiViewModel.isShownCups ? 20 : 0)
            .allowsHitTesting(!ponchiViewModel.isShownCups)
            .overlay {
                if ponchiViewModel.isShownCups {
                    CupsView()
                }
            }
            .overlay(
                Group {
                    if ponchiViewModel.isShownCups {
                        CloseButton(
                            action: {
                                HapticManager.tap()
                                withAnimation {
                                    ponchiViewModel.isShownCups = false
                                }
                            },
                            color: Color.peony
                        )
                        .padding()
                    }
                },
                alignment: .topTrailing
            )
            
            if ponchiViewModel.isShowingDetails {
                Color.black.opacity(0.3)
                    .ignoresSafeArea()
                    .onTapGesture {
                        HapticManager.tap()
                        withAnimation {
                            ponchiViewModel.isShowingDetails = false
                        }
                    }
                PonchiDrinkDetailView()
            }
        }
        .overlay {
            if ponchiViewModel.isLoading {
                ProgressView("Обновляем меню...")
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .background(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
        .overlay(alignment: .top) {
            if ponchiViewModel.showOfflineBanner {
                Text(ponchiViewModel.offlineBannerText)
                    .font(.caviarb(14))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 10)
                    .background(Color.orange.opacity(0.9))
                    .clipShape(Capsule())
                    .padding(.top, 8)
                    .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
    }
}




#Preview {
    PonchiCustomTabBar()
        .environmentObject(Cart())
        .environmentObject(PreviewFactory.makePonchiViewModel())
        .environmentObject(PreviewFactory.makeUserViewModel())
}

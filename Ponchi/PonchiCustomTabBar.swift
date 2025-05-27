//
//  ContentView.swift
//  Ponchi
//
//  Created by mary romanova on 03.09.2024.
//

import SwiftUI

struct PonchiCustomTabBar: View {
    @EnvironmentObject var ponchiViewModel: PonchiViewModel
    @EnvironmentObject var order: Cart

    var body: some View {
        ZStack {
            currentView()
                .onTapGesture {
                            print("Background tapped")
                        }

            VStack {
                Spacer()
                HStack(spacing: 60) {
                    CustomTabButton(imageName: "ponchiHome", isSelected: ponchiViewModel.selectedTab == 0) {
                        ponchiViewModel.selectedTab(0)
                    }
                    
                    CustomCartButton(imageName: "ponchiCart2", isSelected: ponchiViewModel.selectedTab == 2, action: {
                        ponchiViewModel.selectedTab(2)
                    }, badgeCount: order.items.count)
                    
                    CustomTabButton(imageName: "ponchiCheque", isSelected: ponchiViewModel.selectedTab == 3) {
                        ponchiViewModel.selectedTab(3)
                    }
                }
                .padding(.horizontal, 30)
                .padding(.vertical, 16)
                .background(.ultraThinMaterial, in: Capsule())
                .shadow(color: .black.opacity(0.4), radius: 10, x: 0, y: 5)
                .padding(.horizontal)
            }
        }
        .overlay(
            Group {
                if ponchiViewModel.isSelected {
                    PonchiRegistrationView()
                        .environmentObject(ponchiViewModel)
                        .zIndex(2)
                }
            }
        )
    }

    private func currentView() -> some View {
        switch ponchiViewModel.selectedTab {
        case 0:
            return AnyView(PonchiMenuView())
        case 2:
            return AnyView(PonchiCartView())
        case 3:
            return AnyView(PonchiChequeView())
        default:
            return AnyView(PonchiMenuView())
        }
    }
}


#Preview {
    PonchiCustomTabBar().environmentObject(Cart())
        .environmentObject(PonchiViewModel())
}

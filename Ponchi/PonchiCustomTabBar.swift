//
//  ContentView.swift
//  Ponchi
//
//  Created by mary romanova on 03.09.2024.
//

import SwiftUI
import UIKit

struct PonchiCustomTabBar: View {
    
    @StateObject var ponchiViewModel = PonchiViewModel()
    @EnvironmentObject var order: Cart

    var body: some View {
        
        ZStack {
            
            currentView()
            
            VStack {
                
                Spacer()
                
                
                HStack(spacing: 60) {
                    CustomTabButton(imageName: "ponchiHome", isSelected: ponchiViewModel.selectedTab == 0) {
                        ponchiViewModel.selectedTab(0)
                    }
                    
                    CustomCartButton(imageName: "ponchiCart2", isSelected: ponchiViewModel.selectedTab == 2, action:  {
                        ponchiViewModel.selectedTab(2)
                    }, badgeCount: order.items.count)
                    
                    CustomTabButton(imageName: "ponchiCheque", isSelected: ponchiViewModel.selectedTab == 3) { 
                        ponchiViewModel.selectedTab(3)
                    }
                }
                .padding()
                .padding(.horizontal, 15)
                .background(Color.white)
                .cornerRadius(10)
                .shadow(radius: 5)
            }
        }
    }
    
    private func currentView() -> some View {
        switch ponchiViewModel.selectedTab {
        case 0:
            AnyView(PonchiMenuView().environmentObject(ponchiViewModel))
        case 2:
            AnyView(PonchiCartView())
        case 3:
            AnyView(PonchiChequeView())
        default:
            AnyView(PonchiMenuView().environmentObject(ponchiViewModel))
        }
    }
}

#Preview {
    PonchiCustomTabBar().environmentObject(Cart())
}

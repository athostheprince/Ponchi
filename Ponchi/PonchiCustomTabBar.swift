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
    @EnvironmentObject var user: UserViewModel


    var body: some View {
        ZStack {
            currentView()

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
                .background(
                        Capsule()
                               .fill(.ultraThinMaterial)

                )
                .overlay {
                    Capsule()
                        .stroke(Color.peony, lineWidth: 2)
                }
                .shadow(color: .black.opacity(0.4), radius: 10, x: 0, y: 5)
                .padding(.horizontal)
            }
        }
        .overlay {
            if ponchiViewModel.isShowingDetails {
                PonchiDrinkDetailView()
            }
        }
        .overlay(
            Group {
                if user.showProfile {
                    if user.user == nil {
                        PonchiRegistrationView()
                            .environmentObject(user)
                            .zIndex(2)
                    } else {
                        PonchiProfileView()
                            .environmentObject(user)
                            .zIndex(2)
                    }
                }
            }
        )
//        .onAppear {
//            exportPonchiJSON()
//        }

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


private struct PonchiCustomTabBarPreview: View {
    @StateObject private var ponchiViewModel = PreviewFactory.makePonchiViewModel()
    private let cart = Cart()
    private let user = UserViewModel()
    private let order = OrderViewModel()

    var body: some View {
        PonchiCustomTabBar()
            .environmentObject(cart)
            .environmentObject(ponchiViewModel)
            .environmentObject(user)
            .environmentObject(order)
            .task {
                await ponchiViewModel.loadPonchi()
            }
    }
}

#Preview {
    PonchiCustomTabBarPreview()
}

extension Color {
    static let peony: Color = Color(hex: "1ffd7df")
    static let brightGreen = Color(hex: "1a5632")
    static let brightPeony = Color(hex: "DF8992")
    static let matcha = Color(hex: "C3C282")
    static let biege = Color(hex: "E8E2D4")
    static let bronzeYellow = Color(hex: "576100")
    static let softPink = Color(hex: "F7EFDA")
    static let lightWihte = Color(hex: "E8E2D4")
    static let bronzeGreen = Color(hex: "CCC9A4")
    static let paleSilver = Color(hex: "d5c8b5")
}

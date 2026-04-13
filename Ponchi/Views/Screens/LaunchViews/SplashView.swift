//
//  SplashView 2.swift
//  Ponchi
//
//  Created by mary romanova on 31.10.2025.
//


import SwiftUI
import AVKit

struct SplashView: View {
    @EnvironmentObject var ponchiViewModel: PonchiViewModel
    @EnvironmentObject var cart: Cart
    @EnvironmentObject var user: UserViewModel
    @EnvironmentObject var order: OrderViewModel

    @State private var showLogo = false
    @State private var showVideo = false
    @State private var isActive = false

    var body: some View {
        if isActive {
            // 🔹 Основной экран
            PonchiCustomTabBar()
        } else {
            ZStack {
                Color.white.ignoresSafeArea()

                // MARK: - Видео
                if showVideo {
                    VideoPlayerView(videoName: "NewLoadingStar") // mp4 в ассетах
                        .ignoresSafeArea()
                        .transition(.opacity.combined(with: .scale))
                        .opacity(showVideo ? 1 : 0)
                        .animation(.easeInOut(duration: 1.0), value: showVideo)
                }

                // MARK: - Лого поверх
                Image("звездочкиЛого")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 280, height: 280)
                    .scaleEffect(showLogo ? (showVideo ? 1.05 : 1.15) : 0.6)
                    .opacity(showVideo ? 0 : 1)
                    .animation(.spring(response: 0.8, dampingFraction: 0.7), value: showLogo)
                    .animation(.easeInOut(duration: 0.8), value: showVideo)
            }
            .onAppear {
                // 1️⃣ Появление логотипа
                withAnimation(.spring(response: 0.8, dampingFraction: 0.7)) {
                    showLogo = true
                }
                HapticManager.heavyTab()

                // 2️⃣ Через 1.2 секунды — появление видео
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                    withAnimation(.easeInOut(duration: 0.8)) {
                        showVideo = true
                    }
                    HapticManager.mediumTab()
                }

                // 3️⃣ Через 4 секунды — переход к приложению
                DispatchQueue.main.asyncAfter(deadline: .now() + 4.0) {
                    withAnimation(.easeInOut(duration: 0.5)) {
                        isActive = true
                    }
                }
            }
        }
    }
}

#Preview {
    SplashView()
        .environmentObject(PreviewFactory.makePonchiViewModel())
        .environmentObject(Cart())
        .environmentObject(PreviewFactory.makeUserViewModel())
        .environmentObject(OrderViewModel())
}

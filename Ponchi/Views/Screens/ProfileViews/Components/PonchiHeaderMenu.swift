//
//  PonchiHeaderMenu.swift
//  Ponchi
//
//  Created by mary romanova on 03.12.2024.
//

import SwiftUI

struct PonchiHeaderMenu: View {
    
    @EnvironmentObject var ponchiViewModel: PonchiViewModel
    @EnvironmentObject var userViewModel: UserViewModel

    var body: some View {
        VStack {
            HStack {
                UserHeaderView()
                    .onTapGesture {
                        HapticManager.scroll()
                        withAnimation {
                            userViewModel.showProfile.toggle()
                        }
                    }
                
                Spacer()
                
                HStack {
                    Image(systemName: "sparkles")
                        .resizable()
                        .renderingMode(.template)
                        .scaledToFit()
                        .frame(width: 25, height: 25)
                    Text("\(Int(userViewModel.bonusPoints)) ₽")
                        .font(.caviarb(20))
                }
                .padding(10)
                .foregroundStyle(ponchiViewModel.isShownCups ? Color.peony : Color.brightGreen)
                .background(
                    Capsule()
                        .fill(ponchiViewModel.isShownCups ? Color.brightGreen : Color.biege))
                .overlay(
                    Capsule()
                        .stroke(ponchiViewModel.isShownCups ? Color.peony : Color.brightGreen, lineWidth: 2)
                )
                .onTapGesture {
                    HapticManager.tap()
                    withAnimation {
                        ponchiViewModel.isShownCups.toggle()
                    }
                }
            }
            .onTapGesture {
                HapticManager.tap()
                ponchiViewModel.isShownCups = false
            }
        }
    }
}

struct UserHeaderView: View {
    
    @EnvironmentObject var user: UserViewModel
    @State private var shimmer = false
    
    var body: some View {
        HStack {
            ZStack {
                Circle()
                    .fill(Color.matcha)
                
                Image(systemName: "person.fill")
                    .resizable()
                    .scaledToFit()
                    .foregroundStyle(Color.brightGreen)
                    .padding(8)
        
            }
            .frame(width: 50, height: 50)
            .padding(8)
            .overlay {
                Circle()
                    .strokeBorder(
                        AngularGradient(
                            gradient: Gradient(colors: [
                                Color.brightPeony.opacity(0.9),
                                Color.white.opacity(0.8),
                                Color.brightPeony.opacity(0.9)
                            ]),
                            center: .center,
                            angle: .degrees(shimmer ? 360 : 0)
                        ),
                        lineWidth: 3
                    )
                    .animation(
                        .linear(duration: 4)
                        .repeatForever(autoreverses: false),
                        value: shimmer
                    )
                    .shadow(color: .white.opacity(0.6), radius: 2)
            }
            .onAppear {
                shimmer = true
            }

            .padding(8)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(Date().greeting.lowercased() + ",")
                    .font(.caviarb(17))
                               .foregroundStyle(Color.brightGreen)
                           Text(((user.user != nil) ? user.user?.name : "Гость")!)
                               .font(.caviarb(20))
                               .foregroundStyle(Color.brightGreen)
                       }
        }
        //.padding(.horizontal, 15)
//        .overlay {
//            Capsule()
//                .stroke(Color.peony, lineWidth: 2)
//        }
    }
}

struct CupsView: View {
    @State private var isFlipped = false
    
    var body: some View {
        ZStack {
            // Лицевая сторона
            frontCard
                .opacity(isFlipped ? 0 : 1)
                .rotation3DEffect(.degrees(isFlipped ? 180 : 0), axis: (x: 0, y: 1, z: 0))
            
            // Оборотная сторона
            backCard
                .opacity(isFlipped ? 1 : 0)
                .rotation3DEffect(.degrees(isFlipped ? 0 : -180), axis: (x: 0, y: 1, z: 0))
        }
        .frame(width: 350, height: 220)
        .animation(.easeInOut(duration: 0.6), value: isFlipped)
        .onTapGesture {
            HapticManager.scroll()
            isFlipped.toggle()
        }
    }
    
    // Лицевая сторона
    var frontCard: some View {
        ZStack(alignment: .topTrailing) {
            Image("карточкаЛого")
                .resizable()
                .scaledToFit()
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.peony, lineWidth: 2)
                )
            HStack(spacing: 5) {
                Image(systemName: "sparkles")
                    .resizable()
                    .renderingMode(.template)
                    .scaledToFit()
                    .frame(width: 25, height: 25)
                Text("100 бонусов")
                    .font(.caviarb(15))
            }
            .foregroundStyle(Color.peony)
            .padding(3)
            .background(
                Capsule()
                    .fill(.ultraThinMaterial)
                )
            .padding(.vertical)
        }
    }
    
    // Обратная сторона
    var backCard: some View {
        VStack {
            Text("КАЖДАЯ ШЕСТАЯ ЧАШКА В ПОДАРОК!")
                .font(.lepca(20))
                .foregroundStyle(Color.peony)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
            
            VStack(spacing: 20) {
                ForEach(0..<2, id: \.self) { _ in
                    HStack(spacing: 20) {
                        ForEach(0..<3, id: \.self) { _ in
                            Image(systemName: "seal.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(height: 60)
                                .foregroundStyle(Color.accentColor)
                        }
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.brightGreen)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color.peony, lineWidth: 2)
            )
            
//            Text("у вас 100 бонусных рублей")
//                .font(.custom("Kica-PERSONALUSE-Light", size: 15))
//                .foregroundStyle(Color.peony)
        }
        .padding(.horizontal, 20)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.brightGreen)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.peony, lineWidth: 2)
        )
    }
}


#Preview {
    CupsView()
        .environmentObject(PreviewFactory.makeUserViewModel())
        .environmentObject(PreviewFactory.makePonchiViewModel())
}

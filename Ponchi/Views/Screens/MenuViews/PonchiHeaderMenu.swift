//
//  PonchiHeaderMenu.swift
//  Ponchi
//
//  Created by mary romanova on 03.12.2024.
//

import SwiftUI

struct PonchiHeaderMenu: View {
    
    @EnvironmentObject var ponchiViewModel: PonchiViewModel

    var body: some View {
        VStack {
            HStack {
                Text("🐼")
                    .font(.largeTitle)
                VStack(alignment: .leading) {
                    Text("Добрый вечер,")
                        .fontWeight(.medium)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    
                    Text("Гость!")
                        .fontWeight(.medium)
                        .font(.title3)
                }
                .onTapGesture {
                    withAnimation {
                        ponchiViewModel.isSelected.toggle()
                    }
                }
                
                Spacer()
                
                HStack {
                    Image("bean")
                        .resizable()
                        .renderingMode(.template)
                        .scaledToFit()
                        .frame(width: 25, height: 25)
                    Text("100")
                        .font(.callout)
                        .bold()
                }
                .padding()
                .foregroundStyle(ponchiViewModel.isShownCups ? Color.white : Color("brandColor"))
                .background(ponchiViewModel.isShownCups ? Color("brandColor") : Color.white)
                .cornerRadius(10)
                .shadow(radius: 10)
                .onTapGesture {
                    withAnimation {
                        ponchiViewModel.isShownCups.toggle()
                    }
                }
            }
            .onTapGesture {
                ponchiViewModel.isShownCups = false
            }
            if ponchiViewModel.isShownCups {
                CupsView()
            }
        }
    }
}

struct CupsView: View {
    var body: some View {
        ZStack {
            VStack {
                ZStack(alignment: .topLeading) {
                    RoundedRectangle(cornerRadius: 10)
                        .foregroundStyle(Color("brandColor"))
                    
                    Text("Осталось чашек до награды:")
                        .font(.title2)
                        .foregroundStyle(.white)
                        .padding(10)
                }
            }
            .frame(height: 170)
            .padding(5)
            
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .foregroundStyle(Color.white)
                    .frame(height: 80)
                    .padding(10)
                
                HStack {
                    ForEach(0..<6) { cup in
                        Image("coffeeToGo")
                            .resizable()
                            .renderingMode(.template)
                            .scaledToFit()
                    }
                }
                .foregroundStyle(.secondary)
                .padding()
            }
        }
    }
}

#Preview {
    PonchiMenuView()
        .environmentObject(PonchiViewModel())
        .environmentObject(OrderViewModel())
}

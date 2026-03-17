//
//  GlassButton.swift
//  Ponchi
//
//  Created by mary romanova on 12.07.2025.
//


import SwiftUI

struct GlassButton: View {
    var title: String
    var action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title.lowercased())
                .font(.caviarb(20))
                .bold()
                .padding(.horizontal)
                .padding(.vertical, 10)
                .background(
                    ZStack {
                        // почти прозрачное стекло
                        Capsule()
                            .fill(Color.brightGreen)
                        
                        // блик сверху
                       Capsule()
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        Color.white.opacity(0.3),
                                        Color.white.opacity(0.05)
                                    ]),
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .blendMode(.screen)
                    }
                )
                // обводка по краю
                .overlay(
                   Capsule()
                        .stroke(Color.brightGreen, lineWidth: 2)
                )
                // specular-блик сверху
                .overlay(
                   Capsule()
                        .stroke(
                            LinearGradient(
                                gradient: Gradient(stops: [
                                    .init(color: .white.opacity(0.4), location: 0),
                                    .init(color: .clear, location: 0.2)
                                ]),
                                startPoint: .top,
                                endPoint: .bottom
                            ),
                            lineWidth: 2
                        )
                )
                // тень снизу
                //.shadow(color: Color.black.opacity(0.25), radius: 10, x: 0, y: 5)
        }
        .foregroundColor(Color.peony)
    }
}

#Preview {
    GlassButton(title: "добавить в корзину", action: {})
}

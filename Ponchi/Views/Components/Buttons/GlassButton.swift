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
            Text(title)
                .font(.title2)
                .bold()
                .padding(.horizontal, 32)
                .padding(.vertical, 14)
                .background(
                    ZStack {
                        // почти прозрачное стекло
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .fill(.ultraThinMaterial)
                            .opacity(0.6)
                        
                        // блик сверху
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
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
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .stroke(Color.white.opacity(0.3), lineWidth: 1)
                )
                // specular-блик сверху
                .overlay(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
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
        .foregroundColor(.black.opacity(0.5))
    }
}

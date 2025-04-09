//
//  SwiftUIView.swift
//  Ponchi
//
//  Created by mary romanova on 29.11.2024.
//

import SwiftUI

struct CustomTabButton: View {
    
    let imageName: String
    let isSelected: Bool
    let action: () -> Void
    let color = Color("brandColor")

    var body: some View {
        Button(action: action) {
            Image(imageName)
                .resizable()
                .renderingMode(.template)
                .scaledToFit()
                .bold()
                .frame(width: 32, height: 32)
                .foregroundStyle(isSelected ? color : .secondary)
                .shadow(color: Color("brandColor"), radius: isSelected ? 10 : 0)
        }
    }
}

struct CustomCartButton: View {
    
    let imageName: String
    let isSelected: Bool
    let action: () -> Void
    let color = Color("brandColor")
    var badgeCount: Int?
    
    
    var body: some View {
        Button(action: action) {
            ZStack {

                Image(imageName)
                    .resizable()
                    .renderingMode(.template)
                    .scaledToFit()
                    .frame(width: 32, height: 32)
                    .foregroundStyle(isSelected ? color : .secondary)
                    .shadow(color: Color("brandColor"), radius: isSelected ? 10 : 0)
                
                if let badgeCount, badgeCount > 0 {
                    Text("\(badgeCount)")
                        .font(.caption2)
                        .foregroundStyle(.white)
                        .padding(8)
                        .background(Color("brandColor"))
                        .clipShape(Circle())
                        .offset(x: 12, y: -10)
                }
            }
        }
    }
}

struct CurvedShape: View {
    var body: some View {
        Path { path in
            let screenWidth = UIScreen.main.bounds.width
            let arcDepth: CGFloat = 60 // Углубление арки
            let arcRadius: CGFloat = 40 // Радиус арки
            
            path.move(to: CGPoint(x: 0, y: 0))
            path.addLine(to: CGPoint(x: screenWidth, y: 0))
            path.addLine(to: CGPoint(x: screenWidth, y: arcDepth))
            
            // Центр смещается вниз на глубину арки
            path.addArc(center: CGPoint(x: screenWidth / 2, y: arcDepth),
                        radius: arcRadius,
                        startAngle: .zero,
                        endAngle: .init(degrees: 180),
                        clockwise: true)
            
            path.addLine(to: CGPoint(x: 0, y: arcDepth))
        }
        .fill(Color.white)
        .rotationEffect(.init(degrees: 180))
    }
}

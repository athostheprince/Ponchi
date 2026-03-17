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
    let color = Color.brightGreen

    var body: some View {
        Button {
            HapticManager.tap()
            action()
        }
        label: {
            Image(imageName)
                .resizable()
                .renderingMode(.template)
                .scaledToFit()
                .bold()
                .frame(width: 32, height: 32)
                .foregroundStyle(color)
                .shadow(color: Color.brightGreen, radius: isSelected ? 20 : 0)
        }
    }
}

struct CustomCartButton: View {
    
    let imageName: String
    let isSelected: Bool
    let action: () -> Void
    let color = Color.brightGreen
    var badgeCount: Int?
    
    
    var body: some View {
        Button {
            HapticManager.tap()
            action()
        } label: {
            ZStack {
                Image(imageName)
                    .resizable()
                    .renderingMode(.template)
                    .scaledToFit()
                    .frame(width: 32, height: 32)
                    .foregroundStyle(color)
                    .shadow(color: Color.brightGreen, radius: isSelected ? 20 : 0)
                
                if let badgeCount, badgeCount > 0 {
                    Text("\(badgeCount)")
                        .font(.caption2)
                        .foregroundStyle(Color.peony)
                        .padding(8)
                        .background(Color("brandColor"))
                        .clipShape(Circle())
                        .offset(x: 12, y: -10)
                }
            }
        }
    }
}

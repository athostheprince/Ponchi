//
//  LikeButtonView.swift
//  Ponchi
//
//  Created by mary romanova on 07.12.2025.
//

import SwiftUI

struct LikeButtonView: View {
    var isLiked: Bool
    var body: some View {
        ZStack {
            Circle()
                .frame(width: 40, height: 40)
                .foregroundStyle(isLiked ? Color.brightGreen : Color.peony)
                .overlay {
                    Circle()
                        .stroke(Color.brightGreen.opacity(isLiked ? 0 : 0.14), lineWidth: 1)
                }
                .shadow(color: Color.brightPeony.opacity(0.25), radius: 10, x: 0, y: 4)
            
            Image(systemName: "heart.fill")
                .resizable()
                .scaledToFit()
                .frame(height: 24)
                .foregroundStyle(isLiked ? Color.peony : Color.brightGreen)
                .padding(.horizontal)
        }
    }
}

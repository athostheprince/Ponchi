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
                .foregroundStyle(
                    Color.brightGreen
                )
            
            Image(systemName: "heart.fill")
                .resizable()
                .scaledToFit()
                .frame(height: 24)
                .foregroundStyle(isLiked ? Color.peony : .white)
                .padding(.horizontal)
        }
    }
}


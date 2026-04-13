//
//  DetailImageView.swift
//  Ponchi
//
//  Created by mary romanova on 07.12.2025.
//

import SwiftUI

struct DetailImageView: View {
    
    var image: String
    
    var body: some View {
        Image(image)
            .resizable()
            .scaledToFit()
            .padding(.top, 20)
            .mask(
                LinearGradient(
                    gradient: Gradient(stops: [
                        .init(color: .black, location: -0.5),
                        .init(color: .black, location: 0.6),
                        .init(color: .clear, location: 1)
                    ]),
                    startPoint: .bottom,
                    endPoint: .top
                )
            )
            .overlay(
                LinearGradient(
                    colors: [.clear, Color.canvas],
                    startPoint: .bottom,
                    endPoint: .top
                )
                .frame(height: 100),
                alignment: .top
            )
    }
}

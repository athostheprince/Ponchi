//
//  DetailImageView.swift
//  Ponchi
//
//  Created by mary romanova on 07.12.2025.
//

import SwiftUI

struct DetailImagesView: View {
    
    var image: String
    var pages: Int
    var current: Int
    
    var body: some View {
        VStack {
            Image(image)
                .resizable()
                .scaledToFit()
                .frame(maxWidth: .infinity)
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
                .overlay(alignment: .bottom) {
                    LiquidPageIndicator(
                        pages: pages,
                        current: current
                    )
                    .padding(.bottom, 50)
                }
            Spacer()
        }
    }
}

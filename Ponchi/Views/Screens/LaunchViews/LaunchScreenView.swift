//
//  LaunchScreenView.swift
//  Ponchi
//
//  Created by mary romanova on 12.11.2025.
//

import SwiftUI

struct LaunchScreenView: View {
    static let backgroundColor = Color(hex: "#ffe2d5")
    static let logoSize = CGSize(width: 324, height: 453)
    static let titleOffsetY: CGFloat = 188

    var body: some View {
        ZStack {
            Self.backgroundColor
                .ignoresSafeArea()

            Image("LaunchLogo")
                .resizable()
                .scaledToFit()
                .frame(width: Self.logoSize.width, height: Self.logoSize.height)

            Text("PONCHI")
                .font(.lepca(42))
                .foregroundStyle(Color.brightGreen)
                .offset(y: Self.titleOffsetY)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .ignoresSafeArea()
    }
}


#Preview {
    LaunchScreenView()
}

//
//  LaunchScreenView.swift
//  Ponchi
//
//  Created by mary romanova on 12.11.2025.
//

import SwiftUI

import SwiftUI

struct LaunchScreenView: View {
    var body: some View {
        ZStack {
            Color(hex: "#ffe2d5")
                .ignoresSafeArea()
            Image("LaunchLogo")
                .resizable()
                .scaledToFit()
                .frame(width: 324, height: 453)
        }
    }
}


#Preview {
    LaunchScreenView()
}

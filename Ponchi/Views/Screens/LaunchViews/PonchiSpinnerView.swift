//
//  PonchiSpinnerView.swift
//  Ponchi
//
//  Created by mary romanova on 29.04.2026.
//

import SwiftUI

struct PonchiSpinnerView: View {
    @State private var isRotating = false

    var body: some View {
        Image(systemName: "sparkles")
            .font(.system(size: 28, weight: .medium))
            .foregroundStyle(Color.brightGreen)
            .rotationEffect(.degrees(isRotating ? 360 : 0))
            .animation(
                .linear(duration: 1.1)
                .repeatForever(autoreverses: false),
                value: isRotating
            )
            .onAppear {
                isRotating = true
            }
    }
}

#Preview {
    PonchiSpinnerView()
}

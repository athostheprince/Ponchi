//
//  MattePlusButton.swift
//  Ponchi
//
//  Created by mary romanova on 07.12.2025.
//

import SwiftUI

struct MattePlusButton: View {
    var size: CGFloat 
    var action: () -> Void
    var pic: String

    var body: some View {
        Button(action: action) {
            ZStack {
                // Фон: динамический материал (iOS 15+). Он дает "матовый" эффект.
                Circle()
                    .fill(.ultraThinMaterial) // требует iOS15+. Для старых — использовать BlurView (ниже).
                    .frame(width: size, height: size)
                    .overlay(
                        // Тонкая прозрачная граница
                        Circle()
                            .stroke(Color.white.opacity(0.12), lineWidth: 1)
                    )
                    .shadow(color: Color.black.opacity(0.2), radius: 6, x: 0, y: 2)

                // Плюс
                Image(systemName: pic)
                    .font(.system(size: size * 0.44, weight: .semibold))
                    .foregroundStyle(Color.primary) // автоматически адаптируется к светлой/тёмной теме
                    .opacity(0.95)
            }
        }
        .buttonStyle(ScalePressStyle()) // простая анимация нажатия
        .accessibilityLabel("Добавить")
    }
}

// MARK: - Анимация нажатия
struct ScalePressStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.94 : 1.0)
            .opacity(configuration.isPressed ? 0.92 : 1.0)
            .animation(.spring(response: 0.25, dampingFraction: 0.7), value: configuration.isPressed)
    }
}


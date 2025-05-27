//
//  WaveShape.swift
//  Ponchi
//
//  Created by mary romanova on 14.06.2025.
//
import SwiftUI

struct WaveShape: Shape {
    // Значение от 0 до 1 — положение волны по высоте
    var offset: CGFloat

    // Чтобы Shape анимировался, сделаем параметр анимируемым
    var animatableData: CGFloat {
        get { offset }
        set { offset = newValue }
    }

    func path(in rect: CGRect) -> Path {
        var path = Path()

        // Слева — от верхнего края до высоты offset
        path.move(to: .zero)
        path.addLine(to: CGPoint(x: 0, y: rect.height * offset))

        // Кривая волны — с контролируемыми контрольными точками
        path.addCurve(
            to: CGPoint(x: rect.width, y: rect.height * offset),
            control1: CGPoint(x: rect.width * 0.35, y: rect.height * (offset + 0.05)),
            control2: CGPoint(x: rect.width * 0.65, y: rect.height * (offset - 0.05))
        )

        // Справа — вверх до верхнего края
        path.addLine(to: CGPoint(x: rect.width, y: 0))
        path.closeSubpath()

        return path
    }
}

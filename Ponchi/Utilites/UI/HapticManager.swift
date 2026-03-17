//
//  HapticManager.swift
//  Ponchi
//
//  Created by mary romanova on 23.10.2025.
//

import Foundation
import UIKit

final class HapticManager {
    static let shared = HapticManager()
    private init() {}
    
    func impact(_ style: UIImpactFeedbackGenerator.FeedbackStyle) {
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.prepare()
        generator.impactOccurred()
    }
    
    func notification(_ type: UINotificationFeedbackGenerator.FeedbackType) {
        let generator = UINotificationFeedbackGenerator()
        generator.prepare()
        generator.notificationOccurred(type)
    }
    
    func selectionChanged() {
        let generator = UISelectionFeedbackGenerator()
        generator.prepare()
        generator.selectionChanged()
    }
}

extension HapticManager {
    
    static func tap() {
        shared.impact(.light)
    }
    
    static func scroll() {
        shared.selectionChanged()
    }
    
    static func mediumTab() {
        shared.impact(.medium)
    }
    
    static func heavyTab() {
        shared.impact(.rigid)
    }
    
    static func success() {
        shared.notification(.success)
    }
    
    static func warning() {
        shared.notification(.warning)
    }
    
    static func error() {
        shared.notification(.error)
    }
}

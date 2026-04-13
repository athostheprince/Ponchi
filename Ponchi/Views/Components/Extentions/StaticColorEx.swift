//
//  StaticColorEx.swift
//  Ponchi
//
//  Created by mary romanova on 04.11.2025.
//

import SwiftUI

extension Color {
    // MARK: - Brand Foundation
    static let ink = Color(hex: "1A5632")
    static let canvas = Color(hex: "F6EFE3")
    static let peony = Color(hex: "FFD7DF")
    static let brightPeony = Color(hex: "E6B0BF")
    static let matcha = Color(hex: "C3C282")
    static let cream = Color(hex: "EFE8DC")
    
    // MARK: - Semantic Roles
    static let primaryText = ink
    static let primaryAction = ink
    static let menuSurface = matcha
    static let profileSurface = peony
    static let elevatedSurface = brightPeony
    static let neutralSurface = canvas
    static let softStroke = ink.opacity(0.14)
    
    // MARK: - Compatibility Aliases
    static let brightGreen = ink
    static let beige = canvas
    static let biege = canvas
    static let softPink = peony
    static let lightWihte = canvas
    
    // Accent/support colors for badges and seasonal details.
    static let limeGreen = Color(hex: "D2DB76")
    static let bronzeYellow = Color(hex: "576100")
    static let bronzeGreen = Color(hex: "CCC9A4")
    static let paleSilver = Color(hex: "D5C8B5")
}

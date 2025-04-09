//
//  ColorEx.swift
//  Ponchi
//
//  Created by mary romanova on 03.12.2024.
//

import Foundation
import SwiftUI

extension Color {
    init(hex: String) {
        let hexString = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        var rgbValue: UInt64 = 0

        Scanner(string: hexString.hasPrefix("#") ? String(hexString.dropFirst()) : hexString)
            .scanHexInt64(&rgbValue)

        let red = Double((rgbValue & 0xFF0000) >> 16) / 255.0
        let green = Double((rgbValue & 0x00FF00) >> 8) / 255.0
        let blue = Double(rgbValue & 0x0000FF) / 255.0

        self.init(red: red, green: green, blue: blue)
    }
}

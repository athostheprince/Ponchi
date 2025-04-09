//
//  PositionPrefernceKey.swift
//  Ponchi
//
//  Created by mary romanova on 11.12.2024.
//

import Foundation
import SwiftUI

struct SectionPositionPreferenceKey: PreferenceKey {
    
    static var defaultValue: Category? = nil
    
    static func reduce(value: inout Category?, nextValue: () -> Category?) {
        if let newValue = nextValue() {
            value = newValue
        }
    }
    
}

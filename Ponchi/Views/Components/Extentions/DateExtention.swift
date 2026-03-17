//
//  DateExtention.swift
//  Ponchi
//
//  Created by mary romanova on 04.11.2025.
//

import Foundation

extension Date {
    var greeting: String {
        let hour = Calendar.current.component(.hour, from: self)
        
        switch hour {
        case 5..<12:
            return "Доброе утро"
        case 12..<17:
            return "Добрый день"
        case 17..<23:
            return "Добрый вечер"
        default:
            return "Доброй ночи"
        }
    }
}

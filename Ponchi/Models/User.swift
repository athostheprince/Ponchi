//
//  PonchiUserModel.swift
//  Ponchi
//
//  Created by mary romanova on 24.11.2024.
//

import Foundation

struct User: Codable, Identifiable {
    var id: Int
    var name: String
    var number: String 
}

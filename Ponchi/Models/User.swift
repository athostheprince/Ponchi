//
//  PonchiUserModel.swift
//  Ponchi
//
//  Created by mary romanova on 24.11.2024.
//

import Foundation

struct User: Codable, Identifiable {
    var id: String
    var name: String
    var number: String
    var bonuses: Int
    var avatar: String? 
}

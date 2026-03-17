//
//  PromoItem.swift
//  Ponchi
//
//  Created by mary romanova on 28.10.2025.
//

import Foundation
import SwiftUI

struct PromoItem: Identifiable, Hashable {
    let id = UUID()
    let imageName: String
    let title: String
    let description: String
    let type: Category
}

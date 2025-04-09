//
//  PonchiApp.swift
//  Ponchi
//
//  Created by mary romanova on 03.09.2024.
//

import SwiftUI

@main
struct PonchiApp: App {
    
    var cart = Cart()
    var order = OrderViewModel()
    
    init() {
           UITraitCollection.current = UITraitCollection(userInterfaceStyle: .light)
       }
    
    var body: some Scene {
        WindowGroup {
            PonchiCustomTabBar()
                .environmentObject(cart)
                .environmentObject(order)
                .preferredColorScheme(.light)
        }
    }
}

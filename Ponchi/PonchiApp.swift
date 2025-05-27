//
//  PonchiApp.swift
//  Ponchi
//
//  Created by mary romanova on 03.09.2024.
//

import SwiftUI


@main
struct PonchiApp: App {
    var ponchiViewModel = PonchiViewModel()
    var cart = Cart()
    var order = OrderViewModel()

    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate

    init() {
        UITraitCollection.current = UITraitCollection(userInterfaceStyle: .light)
    }

    var body: some Scene {
        WindowGroup {
            PonchiCustomTabBar()
                .environmentObject(cart)
                .environmentObject(order)
                .environmentObject(ponchiViewModel)
                .preferredColorScheme(.light)
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    
        print("Firebase inited")
        return true
    }
}

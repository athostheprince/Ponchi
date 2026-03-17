//
//  AppSettings.swift
//  Ponchi
//
//  Created by mary romanova on 26.01.2026.
//

import Foundation

final class AppSettings {
    static let shared = AppSettings()
    
    private let defaults = UserDefaults.standard
    
    private enum Keys {
        static let launchCount = "launchCount"
        static let onboardingShown = "onboardingShown"
        static let promoWasShown = "promoWasShown"
        static let lastSelectedCategory = "lastSelectedCategory"
    }
    
    var launchCount: Int {
        get { defaults.integer(forKey: Keys.launchCount)}
        set { defaults.set(newValue, forKey: Keys.launchCount)}
    }
    
    var onboardingShown: Bool {
        get { defaults.bool(forKey: Keys.onboardingShown)}
        set { defaults.set(newValue, forKey: Keys.onboardingShown)}
    }
    
    var promoWasShown: Bool {
        get { defaults.bool(forKey: Keys.promoWasShown)}
        set { defaults.set(newValue, forKey: Keys.promoWasShown)}
    }
    
    var lastSelectedCategory: Category? {
        get {
            guard let raw = defaults.string(forKey: Keys.lastSelectedCategory) else { return nil }
            return Category(rawValue: raw)
        }
        set {
            if let raw = newValue?.rawValue {
                defaults.set(raw, forKey: Keys.lastSelectedCategory)
            } else {
                defaults.removeObject(forKey: Keys.lastSelectedCategory)
            }
        }
    }
}

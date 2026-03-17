//
//  UserViewModel.swift
//  Ponchi
//
//  Created by mary romanova on 21.09.2025.
//

import Foundation
import SwiftUI

class UserViewModel: ObservableObject {
    
    @Published var user: User?
    @Published var isLoggedIn: Bool = false
    
    @Published var signUpName: String = ""
    @Published var signUpPhone: String = ""
    @Published var password: String = ""
    @Published var confirmPassword: String = ""
    
    @Published var editName: String = ""
    @Published var editPhone: String = ""
    @Published var isExpanded = false
    @Published var showEditProfile = false
    
    @Published var sheetDetent: PresentationDetent = .medium
    
    @Published var showProfile = false
    @Published var isLiked = false
    @Published var likedDrinks: [Ponchi] = []
    @Published var userIsValid = false
    @Published var bonusPoints: Double = 0
    @Published var likedisShown = false
    @Published var detailViewisExpanded = false
    
    private var sessionKey = "userSessionID"
    
    var isSignUpFormValid: Bool {
        !signUpName.isEmpty &&
        !signUpPhone.isEmpty &&
        !password.isEmpty &&
        password == confirmPassword
    }
    
    var isLoginFormValid: Bool {
        !signUpName.isEmpty &&
        !signUpPhone.isEmpty &&
        !password.isEmpty
    }
    
    private func restoreSession() {
        if let token = KeychainService.shared.read(sessionKey) {
            print("сессия восстановлена \(token)")
            isLoggedIn = true
            showProfile = true
        }
    }
    
    func signUp() {
        guard isSignUpFormValid else { return }
        
        let token = UUID().uuidString
        let success = KeychainService.shared.save(token, for: sessionKey)
        
        guard success else { return }
        
            user = User(
                id: Int.random(in: 1...1000),
                name: signUpName,
                number: signUpPhone,
                bonuses: 0
            )
            
            clearAuthFields()
            showProfile = true
    }
    
    func login() {
        guard isLoginFormValid else { return }
        
        let token = UUID().uuidString
        let success = KeychainService.shared.save(token, for: sessionKey)
        
        guard success else { return }
        
            user = User(
                id: Int.random(in: 1...1000),
                name: signUpName,
                number: signUpPhone,
                bonuses: 0
            )
            
            clearAuthFields()
            showProfile = true
    }
    
    private func clearAuthFields() {
        signUpName = ""
        signUpPhone = ""
        password = ""
        confirmPassword = ""
    }
    

    func startEditing() {
        if let user = user {
            editName = user.name
            editPhone = user.number
        }
    }
    
    func saveEditing() {
        if var currentUser = user {
            currentUser.name = editName
            currentUser.number = editPhone
            user = currentUser
        }
    }
    
    func toggleLiked(_ drink: Ponchi) {
        if likedDrinks.contains(where: { $0.id == drink.id} ) {
            likedDrinks.removeAll { $0 == drink }
        } else {
            likedDrinks.append(drink)
        }
    }
    
    func isLiked(_ drink: Ponchi) -> Bool {
        likedDrinks.contains(where: { $0.id == drink.id })
    }
    
    func logout() {
        
        KeychainService.shared.delete(sessionKey)
        
        user = nil
        showProfile = false
        likedDrinks.removeAll()
        isExpanded = false
        showEditProfile = false
        userIsValid = false
        bonusPoints = 0
        
        clearAuthFields() 
    }
    
    func addBonusPoints(for amount: Int) {
        guard var currentUser = user else { return }
        let bonus = Double(amount) * 0.05
        currentUser.bonuses += Int(bonus)
        user = currentUser
    }
    
    func calculateDiscount(for orderAmount: Int) -> Int {
        let maxDiscount = Double(orderAmount) * 0.5
        return Int(min(bonusPoints, maxDiscount))
    }
    
    func useBonus(for orderAmount: Int) -> Int {
        guard var currentUser = user else { return orderAmount }
        let discount = calculateDiscount(for: orderAmount)
        currentUser.bonuses -= discount
        return orderAmount - discount
    }
    
    func selectAvatar(_ name: String) {
        user?.avatar = name 
    }
    
    func getBonuses() -> Int {
        user?.bonuses ?? 0
    }
}



//
//  UserViewModel.swift
//  Ponchi
//
//  Created by mary romanova on 21.09.2025.
//

import Foundation
import SwiftUI

enum AuthFlow {
    case signUp
    case resetPassword
}

@MainActor
class UserViewModel: ObservableObject {
    // MARK: - User State
    @Published var user: User?
    @Published var isLoggedIn: Bool = false
    @Published var isAuthLoading = false
    @Published var isRestoringSession = false

    // MARK: - Auth Draft
    @Published var authPhone: String = ""
    @Published var signUpName: String = ""
    @Published var password: String = ""
    @Published var confirmPassword: String = ""
    @Published var smsCode: String = ""
    @Published var isAwaitingSMSCode: Bool = false
    @Published var authErrorMessage: String?
    
    //MARK: - Retry Auth
    
    @Published var authFlow: AuthFlow = .signUp
    @Published var newPassword: String = ""
    @Published var confirmNewPassword: String = ""
    @Published var showResetPasswordSheet = false
    @Published var retryAfter: Int = 0

    // MARK: - Profile Editing
    @Published var editName: String = ""
    @Published var editPhone: String = ""
    @Published var showEditProfile = false
    @Published var sheetDetent: PresentationDetent = .medium

    // MARK: - Profile UI
    @Published var showProfile = false
    @Published var isExpanded = false
    @Published var isLiked = false
    @Published var likedDrinks: [Ponchi] = []
    @Published var userIsValid = false
    @Published var likedisShown = false
    @Published var detailViewisExpanded = false
    @Published var bonusPoints: Double = 0

    // MARK: - Dependencies
    private let authService: AuthService
    private let sessionManager: SessionManager

    init(authService: AuthService, sessionManager: SessionManager) {
            self.authService = authService
            self.sessionManager = sessionManager
            self.isLoggedIn = sessionManager.isLoggedIn
        }

    // MARK: - Validation
    var isSignUpFormValid: Bool {
        !signUpName.isEmpty &&
        PhoneNumberFormatter.isValid(authPhone) &&
        !password.isEmpty &&
        password == confirmPassword
    }
    
    var isLoginFormValid: Bool {
        PhoneNumberFormatter.isValid(authPhone) && !password.isEmpty
    }
    
    var isResetPasswordFormValid: Bool {
        PhoneNumberFormatter.isValid(authPhone) &&
        newPassword.count >= 6 &&
        newPassword == confirmNewPassword
    }

    // MARK: - Auth
    func login() async {
        
        guard isLoginFormValid else {
            authErrorMessage = "Введи номер телефона и пароль"
            return
        }
        
        guard !isAuthLoading else { return }
        guard let phone = PhoneNumberFormatter.canonical(from: authPhone) else {
            authErrorMessage = "Неверный номер телефона"
            return
        }
        
        isAuthLoading = true
        authErrorMessage = nil
        defer { isAuthLoading = false }
        
        do {
            let response = try await authService.login(phone: phone, password: password)
            try completeAuth(with: response)
        } catch {
            authErrorMessage = mapAuthError(error)
        }
    }


    func restoreSession() async {
        guard let token = sessionManager.token else { return }

        isRestoringSession = true
        defer { isRestoringSession = false }

        do {
            let apiUser = try await authService.me(token: token)
            user = User(apiUser: apiUser)
            bonusPoints = Double(apiUser.bonuses)
            isLoggedIn = true
            authErrorMessage = nil
        } catch let APIError.server(_, message) where message == "INVALID_TOKEN" {
            sessionManager.clear()
            user = nil
            isLoggedIn = false
        } catch {
            authErrorMessage = "Не удалось проверить сессию. Проверьте интернет."
        }
    }

    func requestSignUpCode() async {
        guard isSignUpFormValid else {
            authErrorMessage = "Проверь имя, номер телефона и совпадение паролей"
            return
        }
        
        guard !isAuthLoading else { return }
        guard let phone = PhoneNumberFormatter.canonical(from: authPhone) else {
            authErrorMessage = "Неверный номер телефона"
            return
        }

        isAuthLoading = true
        authErrorMessage = nil
        defer { isAuthLoading = false }

        do {
            let response = try await authService.requestCode(phone: phone, purpose: "signup")
            smsCode = ""
            authFlow = .signUp
            retryAfter = response.retryAfter
            isAwaitingSMSCode = true
        } catch {
            authErrorMessage = mapAuthError(error)
        }
    }
    
    func verifySignUpCode() async {
        guard let phone = PhoneNumberFormatter.canonical(from: authPhone) else {
            authErrorMessage = "Неверный номер телефона"
            return
        }
        
        guard smsCode.count == 4 else {
            authErrorMessage = "Введи 4 цифры из SMS"
            return
        }
        
        guard !isAuthLoading else { return }

        isAuthLoading = true
        authErrorMessage = nil
        defer { isAuthLoading = false }

        do {
            let response = try await authService.verifyCode(
                phone: phone,
                code: smsCode,
                name: signUpName,
                password: password
            )
            try completeAuth(with: response)
        } catch {
            authErrorMessage = mapAuthError(error)
        }
    }
    
    func requestResetCode() async {
        guard isResetPasswordFormValid else {
            authErrorMessage = "Проверь номер телефона и новый пароль"
            return
        }
        
        guard !isAuthLoading else { return }
        guard let phone = PhoneNumberFormatter.canonical(from: authPhone) else {
            authErrorMessage = "Неверный номер телефона"
            return
        }

        isAuthLoading = true
        authErrorMessage = nil
        defer { isAuthLoading = false }

        do {
            let response = try await authService.requestCode(phone: phone, purpose: "reset")
            smsCode = ""
            authFlow = .resetPassword
            retryAfter = response.retryAfter
            showResetPasswordSheet = false
            await Task.yield()
            isAwaitingSMSCode = true
        } catch {
            authErrorMessage = mapAuthError(error)
        }
    }
    
    func confirmResetPassword() async {
        guard let phone = PhoneNumberFormatter.canonical(from: authPhone) else {
            authErrorMessage = "Неверный номер телефона"
            return
        }
        
        guard smsCode.count == 4 else {
            authErrorMessage = "Введи 4 цифры из SMS"
            return
        }
        
        guard newPassword.count >= 6 else {
            authErrorMessage = "Пароль должен быть не короче 6 символов"
            return
        }
        
        guard newPassword == confirmNewPassword else {
            authErrorMessage = "Пароли не совпадают"
            return
        }
        
        guard !isAuthLoading else { return }

        isAuthLoading = true
        authErrorMessage = nil
        defer { isAuthLoading = false }

        do {
            _ = try await authService.resetPassword(
                phone: phone,
                code: smsCode,
                newPassword: newPassword
            )

            isAwaitingSMSCode = false
            showResetPasswordSheet = false
            password = newPassword
            smsCode = ""
            newPassword = ""
            confirmNewPassword = ""
            retryAfter = 0
            authFlow = .signUp
            authErrorMessage = nil
        } catch {
            authErrorMessage = mapAuthError(error)
        }
    }
    func confirmCode() async {
        switch authFlow {
        case .signUp:
            await verifySignUpCode()
        case .resetPassword:
            await confirmResetPassword()
        }
    }
    
    func resendCode() async {
        switch authFlow {
        case .signUp:
            await requestSignUpCode()
        case .resetPassword:
            await requestResetCode()
        }
    }
    
    func tickResendTimer() {
        if retryAfter > 0 {
            retryAfter -= 1
        }
    }
    
    func cancelSignUpCodeFlow() {
        let shouldRestoreResetSheet = authFlow == .resetPassword
        smsCode = ""
        authErrorMessage = nil
        retryAfter = 0
        isAwaitingSMSCode = false
        showResetPasswordSheet = shouldRestoreResetSheet
    }

    private func clearAuthFields() {
        signUpName = ""
        authPhone = ""
        password = ""
        confirmPassword = ""
        smsCode = ""
        newPassword = ""
        confirmNewPassword = ""
        retryAfter = 0
        authFlow = .signUp
        isAwaitingSMSCode = false
    }
    
    private func completeAuth(with response: AuthSuccessResponse) throws {
        try sessionManager.save(token: response.accessToken)
        user = User(apiUser: response.user)
        bonusPoints = Double(response.user.bonuses) // временно
        isLoggedIn = true
        clearAuthFields()
        showProfile = false
        authErrorMessage = nil
    }


    private func mapAuthError(_ error: Error) -> String {
        if error is SessionManagerError {
            return "Не удалось сохранить сессию на устройстве"
        }

        guard case let APIError.server(_, message) = error else {
            return "Не удалось выполнить запрос. Проверь интернет и попробуй еще раз."
        }

        switch message {
        case "INVALID_PHONE":
            return "Неверный номер телефона"
        case "INVALID_CREDENTIALS":
            return "Неверный номер или пароль"
        case "INVALID_TOKEN":
            return "Сессия истекла"
        case "INVALID_CODE":
            return "Неверный код"
        case "CODE_EXPIRED":
            return "Код истек"
        case "WEAK_PASSWORD":
            return "Пароль слишком короткий"
        case "INVALID_NAME":
            return "Введите имя"
        case "USER_ALREADY_EXISTS":
            return "Пользователь с таким номером уже существует"
        case "TOO_MANY_REQUESTS":
            return "Слишком много запросов, попробуйте позже"
        default:
            return "Что-то пошло не так"
        }
    }

    // MARK: - Profile Editing
    func startEditing() {
        if let user = user {
            editName = user.name
            editPhone = PhoneNumberFormatter.nationalDigits(from: user.number)
        }
    }
    
    func saveEditing() {
        if var currentUser = user {
            currentUser.name = editName
            if let phone = PhoneNumberFormatter.canonical(from: editPhone) {
                currentUser.number = phone
            }
            user = currentUser
        }
    }

    // MARK: - Favorites
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

    // MARK: - Session
    func logout() {
        sessionManager.clear()

        user = nil
        isLoggedIn = false
        showProfile = false
        likedDrinks.removeAll()
        isExpanded = false
        showEditProfile = false
        userIsValid = false
        bonusPoints = 0
        showResetPasswordSheet = false
        retryAfter = 0
        authFlow = .signUp
        
        clearAuthFields() 
    }

    // MARK: - Bonuses
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

    // MARK: - Avatar
    func selectAvatar(_ name: String) {
        user?.avatar = name 
    }
    
    func getBonuses() -> Int {
        user?.bonuses ?? 0
    }
}

enum PhoneNumberFormatter {
    static func digitsOnly(from input: String) -> String {
        input.filter(\.isNumber)
    }
    
    static func nationalDigits(from input: String) -> String {
        var digits = digitsOnly(from: input)
        
        if digits.count >= 11, digits.hasPrefix("7") || digits.hasPrefix("8") {
            digits.removeFirst()
        }
        
        return String(digits.prefix(10))
    }
    
    static func canonical(from input: String) -> String? {
        let digits = nationalDigits(from: input)
        guard digits.count == 10 else { return nil }
        return "+7" + digits
    }
    
    static func isValid(_ input: String) -> Bool {
        canonical(from: input) != nil
    }
    
    static func display(from input: String) -> String {
        let digits = Array(nationalDigits(from: input))
        var result = ""
        
        for (index, digit) in digits.enumerated() {
            switch index {
            case 0:
                result += "("
                result.append(digit)
            case 1, 2:
                result.append(digit)
                if index == 2 { result += ") " }
            case 3, 4, 5:
                result.append(digit)
                if index == 5 { result += "-" }
            case 6, 7:
                result.append(digit)
                if index == 7 { result += "-" }
            default:
                result.append(digit)
            }
        }
        
        return result
    }
}

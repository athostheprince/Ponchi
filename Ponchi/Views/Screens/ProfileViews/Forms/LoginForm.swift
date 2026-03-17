//
//  LoginForm.swift
//  Ponchi
//
//  Created by mary romanova on 12.07.2025.
//


import SwiftUI

struct LoginForm: View {
    @EnvironmentObject var user: UserViewModel

    var body: some View {
        VStack {
            CustomTextField(icon: "person", placeholder: "Имя", text: $user.signUpName)
            CustomTextField(icon: "phone", placeholder: "Телефон", text: $user.signUpPhone, keyboardType: .phonePad)
            CustomTextField(icon: "lock", placeholder: "Пароль", text: $user.password, isSecure: true)

            GlassButton(title: "Войти") {
                if user.isLoginFormValid {
                    // создаём текущего пользователя (локально)
                    user.user = User(
                        id: Int.random(in: 1...1000),
                        name: user.signUpName,
                        number: user.signUpPhone,
                        bonuses: Int(user.bonusPoints)
                    )
                    user.showProfile = false
                    user.signUpName = ""
                    user.signUpPhone = ""
                    user.password = ""
                } else {
                    print("Форма входа заполнена некорректно")
                }
                if user.user != nil {
                    HapticManager.success()
                } else {
                    HapticManager.error()
                }
            }
        }
        .padding()
    }
}


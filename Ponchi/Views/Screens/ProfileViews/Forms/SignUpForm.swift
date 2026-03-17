//
//  SignUpForm.swift
//  Ponchi
//
//  Created by mary romanova on 12.07.2025.
//


import SwiftUI

struct SignUpForm: View {
    @EnvironmentObject var user: UserViewModel

    var body: some View {
        VStack {
            CustomTextField(icon: "person", placeholder: "Имя", text: $user.signUpName)
            CustomTextField(icon: "phone", placeholder: "Телефон", text: $user.signUpPhone, keyboardType: .phonePad)
            CustomTextField(icon: "lock", placeholder: "Пароль", text: $user.password, isSecure: true)
            CustomTextField(icon: "lock", placeholder: "Повторите пароль", text: $user.confirmPassword, isSecure: true)

            GlassButton(title: "Зарегистрироваться") {
                
                if user.isSignUpFormValid {
                    // создаём нового пользователя
                    user.user = User(
                        id: Int.random(in: 1...1000),
                        name: user.signUpName,
                        number: user.signUpPhone,
                        bonuses: Int(user.bonusPoints)
                    )
                    // скрываем регистрацию
                    user.showProfile = false
                    // очищаем поля формы
                    user.signUpName = ""
                    user.signUpPhone = ""
                    user.password = ""
                    user.confirmPassword = ""
                } else {
                    print("Форма заполнена некорректно")
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

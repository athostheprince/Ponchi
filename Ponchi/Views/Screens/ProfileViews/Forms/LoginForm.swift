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
            CustomTextField(icon: "phone",
                            placeholder: "(999) 000-00-00",
                            text: Binding(get: {
                PhoneNumberFormatter.display(from: user.authPhone)
            }, set: { newValue in
                user.authPhone = PhoneNumberFormatter.nationalDigits(from: newValue)
            }),
                            keyboardType: .phonePad,
                            prefix: "+7"
            )
            CustomTextField(icon: "lock", placeholder: "Пароль", text: $user.password, isSecure: true)

            GlassButton(title: "Войти") {
                Task {
                    await user.login()
                }
            }
            
            if let error = user.authErrorMessage {
                Text(error)
                    .foregroundStyle(Color.red)
            }
        }
        .padding()
    }
}


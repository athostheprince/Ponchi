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
            CustomTextField(
                icon: "phone",
                placeholder: "(999) 000-00-00",
                text: Binding(
                    get: {
                        PhoneNumberFormatter.display(from: user.authPhone)
                    },
                    set: { newValue in
                        user.authPhone = PhoneNumberFormatter.nationalDigits(from: newValue)
                    }
                ),
                keyboardType: .phonePad,
                prefix: "+7"
            )
            
            CustomTextField(icon: "lock", placeholder: "Пароль", text: $user.password, isSecure: true)
            CustomTextField(icon: "lock", placeholder: "Повторите пароль", text: $user.confirmPassword, isSecure: true)
            
            
            if let error = user.authErrorMessage {
                Text(error)
                    .foregroundColor(.red)
            }
            
            GlassButton(title: "Подвердить код") {
                Task {
                    
                    await user.requestSignUpCode()
                }
            }
            .disabled(!user.isSignUpFormValid)
            .opacity(user.isSignUpFormValid ? 1 : 0.6)
            
        }
        .padding()
    }
}

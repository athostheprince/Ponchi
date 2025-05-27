//
//  SignUpForm.swift
//  Ponchi
//
//  Created by mary romanova on 12.07.2025.
//


import SwiftUI

struct SignUpForm: View {
    @Binding var firstName: String
    @Binding var phoneNumber: String
    @Binding var password: String

    var body: some View {
        VStack {
            CustomTextField(icon: "person", placeholder: "Имя", text: $firstName)
            CustomTextField(icon: "phone", placeholder: "Телефон", text: $phoneNumber, keyboardType: .phonePad)
            CustomTextField(icon: "lock", placeholder: "Пароль", text: $password, isSecure: true)
            CustomTextField(icon: "lock", placeholder: "Повторите пароль", text: $password, isSecure: true)

            GlassButton(title: "Sign Up", action: {})
        }
        .padding()
    }
}

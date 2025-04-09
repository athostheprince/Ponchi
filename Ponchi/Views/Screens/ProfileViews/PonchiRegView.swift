//
//  PonchiRegView.swift
//  Ponchi
//
//  Created by mary romanova on 09.03.2025.
//

import SwiftUI

struct PonchiRegView: View {
    
    @State private var firstName = ""
        @State private var lastName = ""
        @State private var phoneNumber = ""
        @State private var email = ""
        @State private var password = ""
        @State private var acceptTerms = false
        
    var body: some View {
        ZStack {
            // Фон с градиентом
            LinearGradient(gradient: Gradient(colors: [Color("brandColor"), Color.mint]),
                           startPoint: .topLeading,
                           endPoint: .bottomTrailing)
            .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 20) {
                
                Text("Профиль")
                    .font(.largeTitle)
                    .bold()
                    .foregroundColor(.white)
                    .padding(.bottom, 10)
                
                // Поля ввода
                CustomTextField(icon: "person", placeholder: "Имя", text: $firstName)
                CustomTextField(icon: "phone", placeholder: "Телефон", text: $phoneNumber, keyboardType: .phonePad)
                CustomTextField(icon: "lock", placeholder: "Пароль", text: $password, isSecure: true)
                
                // Toggle с кастомным стилем
                Toggle(isOn: $acceptTerms) {
                    Text("Я принимаю условия использования")
                        .foregroundColor(.white)
                        .font(.system(size: 14))
                }
                .toggleStyle(SwitchToggleStyle(tint: .yellow))
                .padding(.horizontal)
                
                // Кастомная кнопка регистрации
                Button(action: register) {
                    Text("Сохранить")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(acceptTerms ? Color.brown : Color.gray)
                        .cornerRadius(12)
                        .shadow(radius: 5)
                        .scaleEffect(acceptTerms ? 1.0 : 0.95)
                        .animation(.spring(), value: acceptTerms)
                }
                .disabled(!acceptTerms)
                .padding(.horizontal)
            }
            .padding()
        }
        .frame(maxWidth: .infinity)
    }
        
        func register() {
            print("Регистрация: \(firstName) \(lastName) - \(phoneNumber)")
        }
    }

    // 🔹 Кастомный текстфилд с иконкой
    struct CustomTextField: View {
        var icon: String
        var placeholder: String
        @Binding var text: String
        var isSecure: Bool = false
        var keyboardType: UIKeyboardType = .default
        
        var body: some View {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(.white)
                
                if isSecure {
                    SecureField(placeholder, text: $text)
                        .foregroundColor(.white)
                        .textFieldStyle(PlainTextFieldStyle())
                } else {
                    TextField(placeholder, text: $text)
                        .foregroundColor(.white)
                        .textFieldStyle(PlainTextFieldStyle())
                        .keyboardType(keyboardType)
                }
            }
            .padding()
            .background(Color.white.opacity(0.2))
            .cornerRadius(12)
            .shadow(radius: 5)
            .padding(.horizontal)
        }
}

#Preview {
    PonchiRegView()
}

//
//  SignUpForm.swift
//  Ponchi
//
//  Created by mary romanova on 12.07.2025.
//


import SwiftUI

struct SignUpForm: View {
    @EnvironmentObject var user: UserViewModel
    @FocusState private var isNameFocused: Bool
    @FocusState private var isPhoneFocused: Bool
    @FocusState private var isPasswordFocused: Bool
    @FocusState private var isConfirmPasswordFocused: Bool

    var body: some View {
        VStack {
            CustomTextField(
                icon: "person",
                placeholder: "Имя",
                text: $user.signUpName,
                textContentType: .givenName,
                submitLabel: .next,
                onSubmit: focusPhone,
                isFocused: $isNameFocused
            )
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
                prefix: "+7",
                textContentType: .telephoneNumber,
                submitLabel: .next,
                onSubmit: focusPassword,
                isFocused: $isPhoneFocused
            )
            
            CustomTextField(
                icon: "lock",
                placeholder: "Пароль",
                text: $user.password,
                isSecure: true,
                textContentType: .newPassword,
                submitLabel: .next,
                onSubmit: focusConfirmPassword,
                isFocused: $isPasswordFocused
            )
            CustomTextField(
                icon: "lock",
                placeholder: "Повторите пароль",
                text: $user.confirmPassword,
                isSecure: true,
                textContentType: .newPassword,
                submitLabel: .done,
                onSubmit: dismissKeyboard,
                isFocused: $isConfirmPasswordFocused
            )
            
            
            if let error = user.authErrorMessage {
                Text(error)
                    .foregroundColor(.red)
            }
            
            GlassButton(title: "Подвердить код") {
                dismissKeyboard()
                Task {
                    
                    await user.requestSignUpCode()
                }
            }
            .disabled(!user.isSignUpFormValid)
            .opacity(user.isSignUpFormValid ? 1 : 0.6)
            
        }
        .padding()
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()

                if isNameFocused {
                    Button("Далее") {
                        focusPhone()
                    }
                } else if isPhoneFocused {
                    Button("Далее") {
                        focusPassword()
                    }
                } else if isPasswordFocused {
                    Button("Далее") {
                        focusConfirmPassword()
                    }
                } else if isConfirmPasswordFocused {
                    Button("Готово") {
                        dismissKeyboard()
                    }
                }
            }
        }
    }

    private func focusPhone() {
        isNameFocused = false
        isPhoneFocused = true
    }

    private func focusPassword() {
        isPhoneFocused = false
        isPasswordFocused = true
    }

    private func focusConfirmPassword() {
        isPasswordFocused = false
        isConfirmPasswordFocused = true
    }

    private func dismissKeyboard() {
        isNameFocused = false
        isPhoneFocused = false
        isPasswordFocused = false
        isConfirmPasswordFocused = false
        UIApplication.shared.dismissKeyboard()
    }
}

//
//  LoginForm.swift
//  Ponchi
//
//  Created by mary romanova on 12.07.2025.
//


import SwiftUI

struct LoginForm: View {
    @EnvironmentObject var user: UserViewModel
    @FocusState private var isPhoneFocused: Bool
    @FocusState private var isPasswordFocused: Bool

    var body: some View {
        VStack {
            CustomTextField(
                icon: "phone",
                placeholder: "(999) 000-00-00",
                text: Binding(get: {
                    PhoneNumberFormatter.display(from: user.authPhone)
                }, set: { newValue in
                    user.authPhone = PhoneNumberFormatter.nationalDigits(from: newValue)
                }),
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
                textContentType: .password,
                submitLabel: .done,
                onSubmit: dismissKeyboard,
                isFocused: $isPasswordFocused
            )

            GlassButton(title: user.isAuthLoading ? "Входим..." : "Войти") {
                guard !user.isAuthLoading else { return }
                dismissKeyboard()
                Task {
                    await user.login()
                }
            }
            .disabled(!user.isLoginFormValid || user.isAuthLoading)
            .opacity((!user.isLoginFormValid || user.isAuthLoading) ? 0.6 : 1)

            Button("Забыли пароль?") {
                user.authErrorMessage = nil
                user.newPassword = ""
                user.confirmNewPassword = ""
                user.showResetPasswordSheet = true
            }
            .font(.caviar(15))
            .foregroundStyle(Color.brightGreen)

            if let error = user.authErrorMessage {
                Text(error)
                    .foregroundStyle(Color.red)
            }
        }
        .padding()
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()

                if isPhoneFocused {
                    Button("Далее") {
                        focusPassword()
                    }
                } else if isPasswordFocused {
                    Button("Готово") {
                        dismissKeyboard()
                    }
                }
            }
        }
    }

    private func focusPassword() {
        isPhoneFocused = false
        isPasswordFocused = true
    }

    private func dismissKeyboard() {
        isPhoneFocused = false
        isPasswordFocused = false
        UIApplication.shared.dismissKeyboard()
    }
}

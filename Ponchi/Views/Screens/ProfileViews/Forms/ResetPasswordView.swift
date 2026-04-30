//
//  ResetPasswordView.swift
//  Ponchi
//
//  Created by mary romanova on 19.04.2026.
//

import SwiftUI

struct ResetPasswordView: View {
    @EnvironmentObject var user: UserViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 16) {
            Text("СБРОС ПАРОЛЯ")
                .font(.lepca(28))
                .foregroundStyle(Color.brightGreen)

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

            CustomTextField(
                icon: "lock",
                placeholder: "Новый пароль",
                text: $user.newPassword,
                isSecure: true
            )

            CustomTextField(
                icon: "lock",
                placeholder: "Повтори новый пароль",
                text: $user.confirmNewPassword,
                isSecure: true
            )

            if let error = user.authErrorMessage {
                Text(error)
                    .foregroundStyle(Color.red)
            }

            GlassButton(title: user.isAuthLoading ? "Отправляем..." : "Получить код") {
                guard !user.isAuthLoading else { return }
                Task {
                    await user.requestResetCode()
                }
            }
            .disabled(!user.isResetPasswordFormValid || user.isAuthLoading)
            .opacity((!user.isResetPasswordFormValid || user.isAuthLoading) ? 0.6 : 1)

            Button("Отмена") {
                dismiss()
            }
            .font(.caviar(15))
            .foregroundStyle(Color.brightGreen)

            Spacer()
        }
        .padding()
        .background(Color.canvas.ignoresSafeArea())
    }
}

#if DEBUG
private struct ResetPasswordPreviewHost: View {
    @StateObject private var user: UserViewModel

    init(
        phone: String = "",
        newPassword: String = "",
        confirmNewPassword: String = "",
        error: String? = nil
    ) {
        let vm = PreviewFactory.makeUserViewModel()
        vm.authPhone = phone
        vm.newPassword = newPassword
        vm.confirmNewPassword = confirmNewPassword
        vm.authErrorMessage = error
        _user = StateObject(wrappedValue: vm)
    }

    var body: some View {
        ResetPasswordView()
            .environmentObject(user)
    }
}

#Preview("Empty") {
    ResetPasswordPreviewHost()
}

#Preview("Filled") {
    ResetPasswordPreviewHost(
        phone: "9991234567",
        newPassword: "123456",
        confirmNewPassword: "123456"
    )
}

#Preview("Error") {
    ResetPasswordPreviewHost(
        phone: "9991234567",
        newPassword: "123456",
        confirmNewPassword: "654321",
        error: "Пароли не совпадают"
    )
}
#endif

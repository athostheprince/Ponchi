//
//  ConfirmCodeView.swift
//  Ponchi
//
//  Created by mary romanova on 08.04.2026.
//

import SwiftUI

struct ConfirmCodeView: View {
    @EnvironmentObject private var user: UserViewModel
    @FocusState private var isCodeFieldFocused: Bool

    private let codeLength = 4
    @State private var resendIn = 30
    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var body: some View {
        VStack(spacing: 24) {
            HStack {
                Button("Назад") { user.cancelSignUpCodeFlow() }
                    .font(.caviar(18))
                    .foregroundStyle(Color.brightGreen)

                Spacer()

                Text("Подтверждение")
                    .font(.caviarb(20))
                    .foregroundStyle(Color.primaryText)

                Spacer()

                Color.clear.frame(width: 70, height: 1)
            }
            .padding(.top, 20)

            Spacer(minLength: 20)

            Text("Введи код из SMS")
                .font(.caviarb(28))
                .foregroundStyle(Color.primaryText)

            Text("Мы отправили код на +7 \(PhoneNumberFormatter.display(from: user.authPhone))")
                .font(.caviar(16))
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            HStack(spacing: 12) {
                ForEach(0..<codeLength, id: \.self) { index in
                    let symbol = character(at: index)

                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.peony.opacity(symbol == nil ? 0.45 : 1))
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(index == user.smsCode.count ? Color.brightGreen : .clear, lineWidth: 2)
                        )
                        .overlay {
                            Text(symbol.map(String.init) ?? "")
                                .font(.caviarb(26))
                                .foregroundStyle(Color.brightGreen)
                        }
                        .frame(width: 46, height: 58)
                }
            }
            .contentShape(Rectangle())
            .onTapGesture { isCodeFieldFocused = true }

            Text("Отправить заново можно через\n\(timeString)")
                .font(.caviar(16))
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .monospacedDigit()

            if resendIn == 0 {
                Button("Отправить код ещё раз") {
                    Task {
                        await user.requestSignUpCode()
                        resendIn = 30
                        isCodeFieldFocused = true
                    }
                }
                .font(.caviarb(16))
                .foregroundStyle(Color.brightGreen)
            }

            if let error = user.authErrorMessage {
                Text(error)
                    .font(.caviar(14))
                    .foregroundStyle(.red)
            }

            GlassButton(title: "Подтвердить") {
                Task {
                    await user.verifySignUpCode()
                }
            }
            .disabled(user.smsCode.count != codeLength)
            .opacity(user.smsCode.count == codeLength ? 1 : 0.6)

            Spacer()

            TextField("", text: $user.smsCode)
                .keyboardType(.numberPad)
                .textContentType(.oneTimeCode)
                .focused($isCodeFieldFocused)
                .frame(width: 1, height: 1)
                .opacity(0.01)
                .onChange(of: user.smsCode) { oldValue, newValue in
                    let digits = newValue.filter(\.isNumber)
                    user.smsCode = String(digits.prefix(codeLength))
                }
        }
        .padding(.horizontal, 24)
        .background(Color.canvas.ignoresSafeArea())
        .onAppear { isCodeFieldFocused = true }
        .onReceive(timer) { _ in
            if resendIn > 0 { resendIn -= 1 }
        }
    }

    private var timeString: String {
        String(format: "%02d:%02d", resendIn / 60, resendIn % 60)
    }

    private func character(at index: Int) -> Character? {
        guard index < user.smsCode.count else { return nil }
        return Array(user.smsCode)[index]
    }
}


#if DEBUG
private struct ConfirmCodePreviewHost: View {
    @StateObject private var user: UserViewModel

    init(
        phone: String,
        smsCode: String = "",
        error: String? = nil
    ) {
        let vm = PreviewFactory.makeUserViewModel()
        vm.authPhone = phone
        vm.smsCode = smsCode
        vm.authErrorMessage = error
        _user = StateObject(wrappedValue: vm)
    }

    var body: some View {
        ConfirmCodeView()
            .environmentObject(user)
    }
}

#Preview("Empty") {
    ConfirmCodePreviewHost(phone: "9991234567")
}

#Preview("3 Digits") {
    ConfirmCodePreviewHost(
        phone: "9991234567",
        smsCode: "123"
    )
}

#Preview("Error") {
    ConfirmCodePreviewHost(
        phone: "9991234567",
        smsCode: "123456",
        error: "Неверный код"
    )
}
#endif

//
//  PonchiBonusView.swift
//  Ponchi
//
//  Created by mary romanova on 14.10.2025.
//

import SwiftUI

struct PonchiBonusView: View {

    @EnvironmentObject var ponchi: PonchiViewModel
    @EnvironmentObject var user: UserViewModel
    @State private var useBonuses: Bool = false   // ✅ переключатель
    @State private var appliedBonus: Double = 0   // ✅ сколько бонусов применено

    var maxBonusUsage: Double {
        guard let price = ponchi.selectedPonchi?.totalPrice else { return 0 }
        return min(user.bonusPoints, Double(price) * 0.5)
    }

    var finalPrice: Double {
        guard let price = ponchi.selectedPonchi?.totalPrice else { return 0 }
        return Double(price) - (useBonuses ? appliedBonus : 0)
    }

    var body: some View {
        VStack(spacing: 20) {
            if let price = ponchi.selectedPonchi?.totalPrice {

                // Цена и бонусы
                Text("Цена: \(price) ₽")
                    .font(.headline)
                Text("Бонусы на счету: \(user.bonusPoints, specifier: "%.0f") ₽")
                    .foregroundStyle(.secondary)

                // Переключатель использования бонусов
                Toggle(isOn: $useBonuses.animation()) {
                    Text("Использовать бонусы (до 50%)")
                }
                .onChange(of: useBonuses) { oldValue, newValue in
                    if newValue {
                        appliedBonus = maxBonusUsage
                    } else {
                        appliedBonus = 0
                    }
                }
                .tint(.peony)

                // Пояснение
                if useBonuses {
                    Text("Применено бонусов: \(appliedBonus, specifier: "%.0f") ₽")
                        .foregroundStyle(.green)
                }

                // Итоговая сумма
                Text("К оплате: \(finalPrice, specifier: "%.0f") ₽")
                    .font(.title2)
                    .bold()

                // Кнопка оплаты
                Button(action: {
                    let total = price
                    let final = total - Int(appliedBonus)

                    user.bonusPoints -= appliedBonus
                    user.addBonusPoints(for: total)

                    // сброс
                    useBonuses = false
                    appliedBonus = 0

                    print("Оплачено: \(final) ₽")
                }) {
                    Text("Оплатить")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.brightGreen)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                        .bold()
                }
            }
        }
        .padding()
    }
}




private struct PonchiBonusPreview: View {
    private let userVM: UserViewModel = {
        let user = UserViewModel()
        user.bonusPoints = 100
        return user
    }()

    private let ponchiVM: PonchiViewModel = {
        let vm = PreviewFactory.makePonchiViewModel()
        vm.selectedPonchi = MockPonchiData.cappuccino
        return vm
    }()

    var body: some View {
        PonchiBonusView()
            .environmentObject(userVM)
            .environmentObject(ponchiVM)
    }
}

#Preview {
    PonchiBonusPreview()
}

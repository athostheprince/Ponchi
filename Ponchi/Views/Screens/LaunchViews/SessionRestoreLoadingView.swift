//
//  SessionRestoreLoadingView.swift
//  Ponchi
//
//  Created by mary romanova on 29.04.2026.
//

import SwiftUI

struct SessionRestoreLoadingView: View {
    var includesLaunchBackground = true

    var body: some View {
        ZStack {
            if includesLaunchBackground {
                LaunchScreenView()
            }

            VStack(spacing: 18) {
                Spacer()

                PonchiSpinnerView()

                VStack(spacing: 6) {
                    Text("Восстанавливаем сессию")
                        .font(.caviar(16))
                        .foregroundStyle(Color.brightGreen)

                    Text("Почти готово")
                        .font(.caviar(12))
                        .foregroundStyle(Color.brightGreen.opacity(0.6))
                }

                Spacer()
                    .frame(height: 80)
            }
            .padding(.bottom, 40)
        }
    }
}


#Preview {
    SessionRestoreLoadingView()
}

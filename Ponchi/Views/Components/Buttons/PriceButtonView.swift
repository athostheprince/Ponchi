//
//  PriceButtonView.swift
//  Ponchi
//
//  Created by mary romanova on 13.03.2025.
//

import SwiftUI

struct PriceButtonView: View {
    let price: Int

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 30)
                .frame(width: 200, height: 50)
                .foregroundColor(Color("brandColor"))
            Text("₽ \(price)")
                .font(.title3)
                .bold()
                .foregroundStyle(.white)
        }
    }
}

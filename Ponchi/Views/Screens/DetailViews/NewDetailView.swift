//
//  NewDetailView.swift
//  Ponchi
//
//  Created by mary romanova on 23.07.2025.
//

import SwiftUI

struct NewDetailView: View {
    
    var body: some View {
        ZStack(alignment: .top) {
            // Фон: напиток
            Image("ice-latte")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
        }
    }
}


#Preview {
    NewDetailView()
}

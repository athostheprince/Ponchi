//
//  EmptyOrderView.swift
//  Ponchi
//
//  Created by mary romanova on 19.01.2025.
//

import SwiftUI

struct EmptyOrderView: View {
    
    var imageName: String
    var message: String
    
    var body: some View {
        ZStack {
            Color(.systemBackground)
                .edgesIgnoringSafeArea(.all)
            
            VStack {
                Image(imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 150)
                
                Text(message)
                    .font(.title2)
                    .fontWeight(.semibold)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.secondary)
                    .padding()
            }
            .offset(y: -50)
        }
    }
}

#Preview {
    EmptyOrderView(imageName: "emptyOrder", message: "Вы еще ничего не выбрали!")
}

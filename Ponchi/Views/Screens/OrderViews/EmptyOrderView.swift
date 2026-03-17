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
    
    var action: () -> Void
    
    var body: some View {
        ZStack {
            Color(Color.biege)
                .edgesIgnoringSafeArea(.all)
            
            VStack {
                Image(imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 180)
                
                Text(message)
                    .font(.caviarb(25))
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.secondary)
                    .padding()
                
                GlassButton(title: "вернуться в меню", action: withAnimation { action })
                
            }
            .offset(y: -50)
        }
    }
}

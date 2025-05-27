//
//  CustomTextField.swift
//  Ponchi
//
//  Created by mary romanova on 14.06.2025.
//
import SwiftUI

struct CustomTextField: View {
        var icon: String
        var placeholder: String
        @Binding var text: String
        var isSecure: Bool = false
        var keyboardType: UIKeyboardType = .default
        
        var body: some View {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(.white)
                
                if isSecure {
                    SecureField(placeholder, text: $text)
                        .foregroundColor(.white)
                        .textFieldStyle(PlainTextFieldStyle())
                } else {
                    TextField(placeholder, text: $text)
                        .foregroundColor(.white)
                        .textFieldStyle(PlainTextFieldStyle())
                        .keyboardType(keyboardType)
                }
            }
            .padding()
            .background(Color.white.opacity(0.2))
            .cornerRadius(30)
            .shadow(radius: 5)
            .padding(.horizontal)
        }
}

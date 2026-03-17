//
//  Comment.swift
//  Ponchi
//
//  Created by mary romanova on 07.12.2025.
//

import SwiftUI

struct Comment: View {
    var placeholder: String
    @Binding var text: String
    var keyboardType: UIKeyboardType = .default
    var placeholderColor: Color = Color.gray.opacity(0.5)

    var body: some View {
        HStack {
            ZStack(alignment: .leading) {
                if text.isEmpty {
                    Text(placeholder)
                        .font(.caviarb(15))
                        .multilineTextAlignment(.center)
                        .foregroundColor(placeholderColor)
                        .padding(.leading, 4)
                }
                
                TextField("", text: $text)
                    .foregroundColor(Color.brightGreen)
                    .textFieldStyle(PlainTextFieldStyle())
                    .keyboardType(keyboardType)
                
            }
        }
        .padding()
        .cornerRadius(30)
        .overlay(
            RoundedRectangle(cornerRadius: 30)
                .stroke(text.isEmpty ? Color.peony : Color.white, lineWidth: 2)
        )
        .padding(.horizontal)
    }
}


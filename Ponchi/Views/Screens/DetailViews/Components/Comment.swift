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
    var placeholderColor: Color = Color.brightGreen.opacity(0.45)

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
        .background(Color.cream.opacity(0.96))
        .clipShape(RoundedRectangle(cornerRadius: 30, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 30, style: .continuous)
                .stroke(text.isEmpty ? Color.softStroke : Color.brightGreen.opacity(0.3), lineWidth: 1)
        }
        .padding(.horizontal)
    }
}

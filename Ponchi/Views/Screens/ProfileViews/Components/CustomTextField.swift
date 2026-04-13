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
    var placeholderColor: Color = Color.gray
    var prefix: String? = nil
    var textContentType: UITextContentType? = nil

    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(Color.brightGreen)
            
            if let prefix {
                Text(prefix)
                    .foregroundColor(Color.brightGreen)
            }

            ZStack(alignment: .leading) {
                if text.isEmpty {
                    Text(placeholder)
                        .foregroundColor(placeholderColor)
                        .padding(.leading, 4)
                }

                if isSecure {
                    SecureField("", text: $text)
                        .foregroundColor(Color.brightGreen)
                        .textFieldStyle(PlainTextFieldStyle())
                        .textContentType(textContentType)
                } else {
                    TextField("", text: $text)
                        .foregroundColor(Color.brightGreen)
                        .textFieldStyle(PlainTextFieldStyle())
                        .keyboardType(keyboardType)
                        .textContentType(textContentType)
                }
            }
        }
        .padding()
        .background(Color.peony)
        .cornerRadius(30)
        .shadow(radius: 5)
        .overlay(
            RoundedRectangle(cornerRadius: 30)
                .stroke(Color.brightGreen, lineWidth: 2)
        )
        .padding(.horizontal)
    }
}


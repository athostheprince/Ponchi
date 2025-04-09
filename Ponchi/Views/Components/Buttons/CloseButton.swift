//
//  CloseButton.swift
//  Ponchi
//
//  Created by mary romanova on 13.03.2025.
//

import SwiftUI

struct CloseButton: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            ZStack {
                Circle()
                    .stroke(Color("brandColor"), lineWidth: 1)
                    .frame(width: 40, height: 40)
                
                Image(systemName: "xmark")
                    .foregroundStyle(Color("brandColor"))
            }
            .padding(3)
        }
    }
}

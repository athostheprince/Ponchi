//
//  HeaderWithLikeButton.swift
//  Ponchi
//
//  Created by mary romanova on 18.09.2025.
//


import SwiftUI
//import BottomSheetSwiftUI

struct HeaderWithLikeButton: View {
    
    @EnvironmentObject var user: UserViewModel
    @State var ml: String
    @State var name: String
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(ml)
                    .font(.title2)
                    .foregroundStyle(.secondary)
                Text(name)
                    .font(.title)
                    .bold()
            }
            Spacer()
            ZStack {
                Circle()
                    .frame(width: 50, height: 50)
                    .foregroundStyle(Color.peony)
                
                Button {
                    user.isLiked.toggle()
                    
                } label: {
                    Image(systemName: "heart.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 24)
                        .foregroundStyle(user.isLiked ? Color.brightGreen : .white)
                }
            }
        }
        .padding(.horizontal)
        .padding(.top, 10)
    }
}

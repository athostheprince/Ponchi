//
//  PonchiProfileView.swift
//  Ponchi
//
//  Created by mary romanova on 23.09.2025.
//

import SwiftUI

struct PonchiProfileView: View {
    @EnvironmentObject var user: UserViewModel
    @EnvironmentObject var ponchi: PonchiViewModel
    @Namespace private var animation
    
    @ViewBuilder
    private func avatarOption(_ name: String) -> some View {
        Image(name)
            .resizable()
            .scaledToFit()
            .clipShape(Circle())
            .overlay {
                Circle()
                    .stroke(user.user?.avatar == name ? Color.brightGreen : .clear, lineWidth: 1)
            }
            .onTapGesture {
                user.selectAvatar(name)
            }
    }
    
    var columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        
        ZStack {
            Color.softPink.ignoresSafeArea()
            VStack {
                HStack {
                    Spacer()
                    CloseButton(action: {
                        HapticManager.tap()
                        user.showProfile.toggle()
                    }, color: Color.brightGreen)
                }
                .padding(.horizontal, 10)
                
                ScrollView {
                    
                    // 🔹 Секция с юзером
                    VStack {
                        VStack {
                            if user.isExpanded {
                                expandedProfileView
                            } else {
                                collapsedProfileView
                            }
                        }
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(user.isExpanded ? Color.peony : Color.brightGreen, lineWidth: user.isExpanded ? 2 : 1)
                        )
                        
                        VStack {
                            favoriteView
                            
                            if user.likedisShown {
                                if user.likedDrinks.isEmpty {
                                    HStack {
                                        Image(systemName: "sparkles")
                                            .foregroundStyle(.yellow)
                                        Text("Вы пока что ничего не выбрали!")
                                            .font(.custom("Kica-PERSONALUSE-Light", fixedSize: 13))
                                            .foregroundStyle(.secondary)
                                        Image(systemName: "sparkles")
                                            .foregroundStyle(.yellow)
                                    }
                                    .padding(.bottom)
                                } else {
                                    favoriteDrinksView
                                }
                            }
                            
                            addEmailView
                            chatUsView
                        }
                        .padding(.vertical, 20)
                        
                        // 🔹 Выйти
                        Button(role: .destructive) {
                            HapticManager.heavyTab()
                            withAnimation {
                                user.logout()
                            }
                        } label: {
                            Text("ВЫЙТИ ИЗ ПРОФИЛЯ")
                                .font(.custom("Kica-PERSONALUSE-Light", fixedSize: 16))
                                .padding(.horizontal, 20)
                                .padding(.vertical, 15)
                                .background(Color.brightGreen)
                                .foregroundColor(Color.peony)
                                .clipShape(Capsule())
                        }
                    }
                    .padding()
                    .animation(.spring(response: 0.5, dampingFraction: 0.6), value: user.isExpanded)
                }
            }
        }
        .sheet(isPresented: $user.showEditProfile) {
            EditProfileView()
                .environmentObject(user)
                .presentationDetents([.medium, .large], selection: $user.sheetDetent)
                .presentationDragIndicator(.visible)
        }
        .overlay {
            if user.detailViewisExpanded {
                PonchiDrinkDetailView()
            }
        }

    }
    
    var expandedProfileView: some View {
        VStack {
            profileImage
                .matchedGeometryEffect(id: "profileImage", in: animation)
                .frame(width: 150, height: 150)
            VStack {
                VStack {
                    Text(user.user?.name ?? "Мария")
                        .matchedGeometryEffect(id: "name", in: animation)
                        .font(.custom("Kica-PERSONALUSE-Light", fixedSize: 20))
                    
                    Text(user.user?.number ?? "+79679673215")
                        .matchedGeometryEffect(id: "title", in: animation)
                        .font(.custom("Kica-PERSONALUSE-Light", fixedSize: 17))
                        .foregroundColor(Color.brightGreen)
                }
                .padding()
                
                Button(role: .destructive) {
                    HapticManager.tap()
                    user.showEditProfile.toggle()
                } label: {
                    Text("РЕДАКТИРОВАТЬ")
                        .font(.custom("Kica-PERSONALUSE-Light", fixedSize: 16))
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .background(Color.brightGreen)
                        .foregroundColor(Color.peony)
                        .clipShape(Capsule())
                }

            }
        }
        .padding()
        .onTapGesture {
            HapticManager.tap()
            user.isExpanded.toggle()
        }
    }

    var collapsedProfileView: some View {
        HStack {
            profileImage
                .matchedGeometryEffect(id: "profileImage", in: animation)
                .frame(width: 100, height: 100)
                //.padding(.horizontal)
            
            VStack(alignment: .leading) {
                Text(user.user?.name ?? "Мария")
                    .matchedGeometryEffect(id: "name", in: animation)
                    .font(.custom("Kica-PERSONALUSE-Light", fixedSize: 20))

                Text(user.user?.number ?? "+79679673215")
                    .matchedGeometryEffect(id: "title", in: animation)
                    .font(.custom("Kica-PERSONALUSE-Light", fixedSize: 17))
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .onTapGesture {
            withAnimation {
                HapticManager.tap()
                user.isExpanded.toggle()
            }
        }
    }

    var profileImage: some View {
        ZStack {
            if ((user.user?.avatar) != nil) {
                
            } else {
                Circle()
                    .fill(user.isExpanded ? Color.peony : Color.matcha)
                Image(systemName: "sparkles")
                    .resizable()
                    .scaledToFit()
                    .foregroundStyle(user.isExpanded ? Color.brightGreen : Color.peony)
                    .padding()
            }
        }
    }
    
    var favoriteView: some View {
        HStack {
            Text("ИЗБРАННОЕ")
                .font(.caviarb(18))
            
            Spacer()
            
            Button {
                HapticManager.tap()
                withAnimation {
                    user.likedisShown.toggle()
                }
            } label: {
                withAnimation {
                    Image(systemName: user.likedisShown ? "chevron.down" : "chevron.right")
                }
            }
        }
        .padding()
        .foregroundStyle(Color.brightGreen)
        .background(Color.peony)
        .cornerRadius(16)
    }
    
    var favoriteDrinksView: some View {
        LazyVGrid(columns: columns, spacing: 10) {
            ForEach(user.likedDrinks) { item in
                favoriteDrinkImageView(image: item.image)
                    .onTapGesture {
                        HapticManager.tap()
                        withAnimation {
                            user.detailViewisExpanded.toggle()
                            ponchi.selectedPonchi = item
                        }
                    }
            }
        }
        .padding(.horizontal, 10)

    }
    
    var addEmailView: some View {
        HStack {
            Text("ПОЧТА ДЛЯ ЧЕКОВ")
                .font(.custom("Kica-PERSONALUSE-Light", fixedSize: 15))
            
            Spacer()
            
            Button {
                HapticManager.error()
            } label: {
                Image(systemName: "plus")
            }
        }
        .padding()
        .foregroundStyle(Color.brightGreen)
        .background(Color.peony)
        .cornerRadius(16)
    }
    
    var chatUsView: some View {
        HStack {
            Text("НАПИШИТЕ НАМ")
                .font(.custom("Kica-PERSONALUSE-Light", fixedSize: 15))
            
            Spacer()
            
            Button {
                HapticManager.error()
            } label: {
                Image(systemName: "message")
            }
        }
        .padding()
        .foregroundStyle(Color.brightGreen)
        .background(Color.peony)
        .cornerRadius(16)
    }
}

private struct PonchiProfilePreview: View {
    private let mockUser: UserViewModel = {
        let user = UserViewModel()
        user.user = User(id: 1, name: "Мария", number: "89679673215", bonuses: 120)
        user.likedDrinks = [
            MockPonchiData.cappuccino,
            MockPonchiData.latte,
            MockPonchiData.raf,
            MockPonchiData.espresso,
            MockPonchiData.flat,
            MockPonchiData.americano
        ]
        return user
    }()
    
    var body: some View {
        PonchiProfileView()
            .environmentObject(mockUser)
            .environmentObject(PreviewFactory.makePonchiViewModel())
    }
}

#Preview {
    PonchiProfilePreview()
}


struct EditProfileView: View {
    @EnvironmentObject var auth: UserViewModel
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        
        VStack(spacing: 20) {
            
            Text("РЕДАКТИРОВАНИЕ ПРОФИЛЯ")
                .font(.custom("Kica-PERSONALUSE-Light", fixedSize: 20))
                .foregroundStyle(Color.brightGreen)
                .multilineTextAlignment(.center)
                .padding(.vertical)
            
            CustomTextField(icon: "person", placeholder: "Имя", text: $auth.editName)
            CustomTextField(icon: "phone", placeholder: "Телефон", text: $auth.editPhone, keyboardType: .phonePad)
            
            Button {
                HapticManager.tap()
                auth.saveEditing()
                auth.showEditProfile.toggle()
            } label: {
                Text("СОХРАНИТЬ")
                    .font(.custom("Kica-PERSONALUSE-Light", fixedSize: 16))
                    .padding(.horizontal, 20)
                    .padding(.vertical, 15)
                    .background(Color.brightGreen)
                    .foregroundColor(Color.peony)
                    .clipShape(Capsule())
            }
            
            Spacer()
        }
        .padding()
        .onAppear {
            auth.startEditing()
            
            NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillShowNotification, object: nil, queue: .main) { _ in
                withAnimation {
                    auth.sheetDetent = .large
                }
            }
            NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillHideNotification, object: nil, queue: .main) { _ in
                withAnimation {
                    auth.sheetDetent = .medium
                }
            }
        }
        .onDisappear {
            NotificationCenter.default.removeObserver(self)
        }
    }
}

struct favoriteDrinkImageView: View {
    
    var image: String
    
    var body: some View {
        Image(image)
            .resizable()
            .scaledToFit()
            .clipShape(Circle())
            .frame(width: 80)
    }
}

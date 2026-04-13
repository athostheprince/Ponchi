//
//  PonchiProfileView.swift
//  Ponchi
//
//  Created by mary romanova on 23.09.2025.
//

import Combine
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
    
    var body: some View {
        
        ZStack {
            Color.peony.ignoresSafeArea()
            VStack {
                HStack {
                    
                    Spacer()
                    
                    Text("ПРОФИЛЬ")
                        .font(.lepca(40))
                        .foregroundStyle(Color.brightGreen)
                    
                    Spacer()
                    
                    CloseButton(action: {
                        HapticManager.tap()
                        user.showProfile.toggle()
                    }, color: Color.brightGreen)
                }
                .padding(10)
                
                ScrollView {
                    
                    VStack {
                        VStack {
                            if user.isExpanded {
                                expandedProfileView
                            } else {
                                collapsedProfileView
                            }
                        }
                        .background(
                            Color.brightPeony)
                        .cornerRadius(20)
                        
                        VStack {
                            ProfileFavoritesSection(
                                favorites: user.likedDrinks,
                                isExpanded: user.likedisShown,
                                onToggle: toggleFavorites,
                                onSelect: openFavorite
                            )
                            addEmailView
                            chatUsView
                        }
                        .padding(.vertical, 20)
                        
                        Button(role: .destructive) {
                            HapticManager.heavyTab()
                            withAnimation {
                                user.logout()
                            }
                        } label: {
                            Text("ВЫЙТИ ИЗ ПРОФИЛЯ")
                                .font(.caviarb(15))
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
                        .font(.caviarb(20))
                        .foregroundStyle(Color.peony)
                    
                    Text(user.user?.number ?? "+79679673215")
                        .matchedGeometryEffect(id: "title", in: animation)
                        .font(.caviarb(15))
                        .foregroundColor(Color.brightGreen)
                }
                .padding()
                
                Button(role: .destructive) {
                    HapticManager.tap()
                    user.showEditProfile.toggle()
                } label: {
                    Text("РЕДАКТИРОВАТЬ")
                        .font(.caviarb(15))
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
                    .font(.caviarb(17))
                    .foregroundStyle(Color.white)

                Text(user.user?.number ?? "+79679673215")
                    .matchedGeometryEffect(id: "title", in: animation)
                    .font(.caviarb(15))
                    .foregroundColor(.white)
                
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
    
    private func toggleFavorites() {
        HapticManager.tap()
        withAnimation(.spring(response: 0.45, dampingFraction: 0.82)) {
            user.likedisShown.toggle()
        }
    }
    
    private func openFavorite(_ item: Ponchi) {
        HapticManager.tap()
        withAnimation(.spring(response: 0.4, dampingFraction: 0.86)) {
            ponchi.selectedPonchi = item
            user.detailViewisExpanded = true
        }
    }
    
    var addEmailView: some View {
        HStack {
            Text("ПОЧТА ДЛЯ ЧЕКОВ")
                .font(.caviarb(15))
            
            Spacer()
            
            Button {
                HapticManager.error()
            } label: {
                Image(systemName: "plus")
            }
        }
        .padding()
        .foregroundStyle(Color.white)
        .background(Color.brightPeony)
        .cornerRadius(16)
    }
    
    var chatUsView: some View {
        HStack {
            Text("НАПИШИТЕ НАМ")
                .font(.caviarb(15))
            
            Spacer()
            
            Button {
                HapticManager.error()
            } label: {
                Image(systemName: "message")
            }
        }
        .padding()
        .foregroundStyle(Color.white)
        .background(Color.brightPeony)
        .cornerRadius(16)
    }
}

private struct PonchiProfilePreview: View {
    private let mockUser: UserViewModel = {
        let user = PreviewFactory.makeUserViewModel()
        user.user = User(id: "1", name: "Мария", number: "89679673215", bonuses: 120)
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
                .font(.caviar(15))
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
                    .font(.caviar(15))
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
        }
        .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)) { _ in
            Task { @MainActor in
                withAnimation {
                    auth.sheetDetent = .large
                }
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)) { _ in
            Task { @MainActor in
                withAnimation {
                    auth.sheetDetent = .medium
                }
            }
        }
    }
}

private struct ProfileFavoritesSection: View {
    let favorites: [Ponchi]
    let isExpanded: Bool
    let onToggle: () -> Void
    let onSelect: (Ponchi) -> Void
    
    var body: some View {
        VStack(spacing: 12) {
            ProfileFavoritesHeader(
                favoritesCount: favorites.count,
                isExpanded: isExpanded,
                onToggle: onToggle
            )
            
            if isExpanded {
                ProfileFavoritesExpandedContent(
                    favorites: favorites,
                    onSelect: onSelect
                )
            } else if !favorites.isEmpty {
                ProfileFavoritesCollapsedPreview(favorites: favorites)
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .foregroundStyle(Color.white)
        .background(Color.brightPeony)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(Color.white.opacity(0.12), lineWidth: 1)
        }
        .animation(.spring(response: 0.35, dampingFraction: 0.85), value: isExpanded)
    }
}

private struct ProfileFavoritesHeader: View {
    let favoritesCount: Int
    let isExpanded: Bool
    let onToggle: () -> Void
    
    private var subtitle: String {
        if favoritesCount == 0 {
            return "Добавляй напитки через сердечко"
        }
        
        return "\(favoritesCount) любимых позиций"
    }
    
    var body: some View {
        Button(action: onToggle) {
            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("ИЗБРАННОЕ")
                        .font(.caviarb(16))
                    
                    Text(subtitle)
                        .font(.caviar(12))
                        .foregroundStyle(Color.white.opacity(0.82))
                }
                
                Spacer()
                
                HStack(spacing: 8) {
                    Image(systemName: "heart.fill")
                        .font(.system(size: 12, weight: .bold))
                    
                    Text("\(favoritesCount)")
                        .font(.caviarb(12))
                    
                    Image(systemName: "chevron.down")
                        .font(.system(size: 11, weight: .bold))
                        .rotationEffect(.degrees(isExpanded ? 180 : 0))
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
                .background(Color.white.opacity(0.14))
                .clipShape(Capsule())
            }
        }
        .buttonStyle(.plain)
    }
}

private struct ProfileFavoritesCollapsedPreview: View {
    let favorites: [Ponchi]
    
    private var previewItems: [Ponchi] {
        Array(favorites.prefix(3))
    }
    
    var body: some View {
        HStack(spacing: 12) {
            HStack(spacing: -12) {
                ForEach(Array(previewItems.enumerated()), id: \.element.id) { _, item in
                    ProfileFavoriteBubble(image: item.image)
                }
            }
            
            Text("Нажми, чтобы быстро открыть любимые напитки.")
                .font(.caviar(12))
                .foregroundStyle(Color.white.opacity(0.85))
            
            Spacer()
        }
        .padding(12)
        .background(Color.white.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}

private struct ProfileFavoritesExpandedContent: View {
    let favorites: [Ponchi]
    let onSelect: (Ponchi) -> Void
    
    var body: some View {
        VStack(spacing: 10) {
            if favorites.isEmpty {
                ProfileFavoritesEmptyState()
            } else {
                ForEach(Array(favorites.enumerated()), id: \.element.id) { index, item in
                    ProfileFavoriteRow(
                        item: item,
                        isFirst: index == 0,
                        onTap: {
                            onSelect(item)
                        }
                    )
                }
            }
        }
        .transition(.opacity.combined(with: .move(edge: .top)))
    }
}

private struct ProfileFavoriteRow: View {
    let item: Ponchi
    let isFirst: Bool
    let onTap: () -> Void
    
    private var subtitle: String {
        if item.ml.isEmpty {
            return item.category.rawValue
        }
        
        return "\(item.category.rawValue) • \(item.ml)"
    }
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                ProfileFavoriteBubble(image: item.image)
                
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 8) {
                        Text(item.name)
                            .font(.caviarb(14))
                            .lineLimit(1)
                        
                        if isFirst {
                            Text("первый")
                                .font(.caviar(10))
                                .padding(.horizontal, 6)
                                .padding(.vertical, 3)
                                .background(Color.white.opacity(0.14))
                                .clipShape(Capsule())
                        }
                    }
                    
                    Text(subtitle)
                        .font(.caviar(11))
                        .foregroundStyle(Color.white.opacity(0.82))
                        .lineLimit(1)
                }
                
                Spacer()
                
                Text("\(item.totalPrice) ₽")
                    .font(.caviarb(13))
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundStyle(Color.white.opacity(0.8))
            }
            .padding(12)
            .background(Color.white.opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        }
        .buttonStyle(.plain)
    }
}

private struct ProfileFavoriteBubble: View {
    let image: String
    
    var body: some View {
        
        Image(image)
            .resizable()
            .scaledToFit()
            .clipShape(Circle())
            .frame(width: 48, height: 48)
    }
}

private struct ProfileFavoritesEmptyState: View {
    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: "sparkles")
                .font(.system(size: 15, weight: .semibold))
            
            Text("Пока пусто. Как только отметишь напиток сердечком, он появится здесь.")
                .font(.caviar(12))
                .foregroundStyle(Color.white.opacity(0.88))
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}

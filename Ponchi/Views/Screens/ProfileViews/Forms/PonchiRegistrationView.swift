//
//  TestView.swift
//  Ponchi
//
//  Created by mary romanova on 14.06.2025.
//
import SwiftUI

struct PonchiRegistrationView: View {
    // MARK: - State
    
    @EnvironmentObject var ponchiViewmodel: PonchiViewModel
    @EnvironmentObject var user: UserViewModel
    
    @State private var selectedTab: TabType = .signup
    @State private var firstName = ""
    @State private var phoneNumber = ""
    @State private var password = ""
    
    @State private var appearBounce = false

    // MARK: - Animation
    private let transitionAnimation = Animation.spring(response: 0.5, dampingFraction: 0.7)

    var body: some View {
        GeometryReader { geo in
            ZStack {
                Color.white
                    .ignoresSafeArea()

                ZStack(alignment: .bottom) {
                    LinearGradient(gradient: Gradient(colors: [Color.peony, Color.peony.opacity(0.6)]),
                                   startPoint: .topLeading,
                                   endPoint: .bottomTrailing)

                    Image("регистрация")
                        .resizable()
                        .scaledToFit()
                        .offset(
                            y: selectedTab == .signup
                            ? geo.size.height * 0.05
                            : geo.size.height * 0.07
                        )
                        .rotation3DEffect(
                            .degrees(selectedTab == .signup ? -8 : 8),
                            axis: (x: 1, y: 0, z: 0)
                        )
                        .rotationEffect(.degrees(selectedTab == .signup ? 180 : 0))
                        .scaleEffect(selectedTab == .signup ? 0.9 : 1)
                        .animation(.spring(response: 0.5, dampingFraction: 0.7), value: selectedTab)


                }
                .ignoresSafeArea()
                .mask(
                    Capsule()
                        .frame(height: geo.size.height * 1.3)
                        .offset(y: selectedTab == .signup ? -geo.size.height * 0.25 : geo.size.height * 0.25)
                        .animation(transitionAnimation, value: selectedTab)
                    
                )

                // MARK: - Tab Buttons
                VStack(spacing: 50) {
                    Button {
                        HapticManager.heavyTab()
                        withAnimation(transitionAnimation) {
                            selectedTab = .signup
                        }
                    } label: {
                        Text("РЕГИСТРАЦИЯ")
                            .font(.lepca(30))
                            .bold()
                            .foregroundStyle(selectedTab == .signup ? Color.brightGreen : .gray)
                            .scaleEffect(selectedTab == .signup ? 1.2 : 1)
                            .animation(transitionAnimation, value: selectedTab)
                    }
                    .padding(.top, 40)
                    .offset(y: selectedTab == .signup ? -geo.size.height / 3.5 : -geo.size.height / 2.4)

                    Button {
                        HapticManager.heavyTab()
                        withAnimation(transitionAnimation) {
                            selectedTab = .login
                        }
                    } label: {
                        Text("ВОЙТИ")
                            .font(.lepca(30))
                            .bold()
                            .foregroundStyle(selectedTab == .login ? Color.brightGreen : .gray)
                            .scaleEffect(selectedTab == .login ? 1.2 : 1)
                            .animation(transitionAnimation, value: selectedTab)
                    }
                    .offset(y: selectedTab == .login ? -geo.size.height / 3 : geo.size.height / 2.6)
                }

                // MARK: - Forms
                VStack(spacing: 20) {
                    if selectedTab == .login {
                        LoginForm()
                            .environmentObject(user)
                            .offset(y: -geo.size.height * 0.05)
                    } else {
                        SignUpForm()
                            .environmentObject(user)
                            .offset(y: -geo.size.height * 0.07)
                    }
                }
                .frame(maxWidth: .infinity)
            }
            .overlay(alignment: .topTrailing) {
                CloseButton(action: {
                    HapticManager.heavyTab()
                    withAnimation {
                        user.showProfile = false 
                    }
                }, color: selectedTab == .signup ? Color.brightGreen : Color("brandColor"))
                .padding()
            }
            .fullScreenCover(isPresented: $user.isAwaitingSMSCode) {
                ConfirmCodeView()
                    .environmentObject(user)
            }
            .contentShape(Rectangle())
            .onTapGesture {
                UIApplication.shared.dismissKeyboard()
            }
        }
        .ignoresSafeArea(.keyboard, edges: .bottom)
        .sheet(isPresented: $user.showResetPasswordSheet) {
            ResetPasswordView()
                .environmentObject(user)
                .presentationDetents([.medium, .large])
        }
    }
}

// MARK: - Tab Type
enum TabType {
    case signup, login
}

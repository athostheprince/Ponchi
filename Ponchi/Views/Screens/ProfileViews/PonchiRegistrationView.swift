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
    
    @State private var selectedTab: TabType = .signup
    @State private var firstName = ""
    @State private var phoneNumber = ""
    @State private var password = ""

    // MARK: - Animation
    private let transitionAnimation = Animation.spring(response: 0.5, dampingFraction: 0.7)

    var body: some View {
        GeometryReader { geo in
            ZStack {
                Color.white
                    .ignoresSafeArea()

                ZStack(alignment: .bottom) {
                    LinearGradient(gradient: Gradient(colors: [Color("brandColor"), Color("brandColor").opacity(0.3)]),
                                   startPoint: .topLeading,
                                   endPoint: .bottomTrailing)

                    Image("капуч 1")
                        .resizable()
                        .scaledToFit()
                        .scaleEffect(1.7)
                        .offset(y: selectedTab == .login ? geo.size.height * 0.1 : -geo.size.height * 0)
                        .animation(transitionAnimation, value: selectedTab)
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
                        withAnimation(transitionAnimation) {
                            selectedTab = .signup
                        }
                    } label: {
                        Text("Sign Up")
                            .font(.largeTitle)
                            .bold()
                            .foregroundStyle(selectedTab == .signup ? .white : .gray)
                            .scaleEffect(selectedTab == .signup ? 1.2 : 1)
                            .animation(transitionAnimation, value: selectedTab)
                    }
                    .padding(.top, 40)
                    .offset(y: selectedTab == .signup ? -geo.size.height / 3.5 : -geo.size.height / 2.4)

                    Button {
                        withAnimation(transitionAnimation) {
                            selectedTab = .login
                        }
                    } label: {
                        Text("Log In")
                            .font(.largeTitle)
                            .bold()
                            .foregroundStyle(selectedTab == .login ? .white : .gray)
                            .scaleEffect(selectedTab == .login ? 1.2 : 1)
                            .animation(transitionAnimation, value: selectedTab)
                    }
                    .offset(y: selectedTab == .login ? -geo.size.height / 3.7 : geo.size.height / 2.6)
                }

                // MARK: - Forms
                VStack(spacing: 20) {
                    if selectedTab == .login {
                        LoginForm(firstName: $firstName, phoneNumber: $phoneNumber, password: $password)
                            .offset(y: geo.size.height * 0.05)
                    } else {
                        SignUpForm(firstName: $firstName, phoneNumber: $phoneNumber, password: $password)
                            .offset(y: -geo.size.height * 0.05)
                    }
                }
                .frame(maxWidth: .infinity)
            }
            .overlay(alignment: .topTrailing) {
                CloseButton(action: {
                    withAnimation {
                        ponchiViewmodel.isSelected = false
                    }
                }, color: selectedTab == .signup ? .white : Color("brandColor"))
                .padding()
            }
            //.ignoresSafeArea()
        }
    }
}

// MARK: - Tab Type
enum TabType {
    case signup, login
}

#Preview {
    PonchiRegistrationView()
}



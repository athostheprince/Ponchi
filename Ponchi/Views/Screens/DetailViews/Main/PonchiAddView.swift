//
//  PonchiAddView.swift
//  Ponchi
//
//  Created by mary romanova on 24.10.2025.
//

import SwiftUI
struct PonchiAddView: View {
    
    let items: [Ponchi]
    
    @Binding var selectedIndex: Int?
    var animationNamespace: Namespace.ID
    
    var cartAction: () -> Void
    var plusAction: (Ponchi) -> Void
    
    var closeAction: () -> Void
    
    let arrayofFood: [Image] = []

    var body: some View {
        VStack(alignment: .center) {
            Text("попробуйте вместе:")
                .font(.caviarb(25))
                .foregroundStyle(Color.brightGreen)
                .padding(.horizontal, 20)
            HStack {
                ForEach(items.indices, id: \.self) { index in
                    let item = items[index]
                    VStack {
                        Image(item.image)
                            .resizable()
                            .scaledToFit()
                            .clipShape(RoundedRectangle(cornerRadius: 20))
                            .clipped()
                            .matchedGeometryEffect(id: index, in: animationNamespace)
                        
                            .overlay(alignment: .bottomTrailing, content: {
                                MattePlusButton(
                                    size: 40,
                                    action: {
                                        plusAction(item)
                                    },
                                    pic: "plus"
                                )
                                    .padding(3)
                            })
                        
                            .onTapGesture {
                                HapticManager.tap()
                                withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                                    selectedIndex = index
                                }
                            }
                        
                        Text(item.name.uppercased())
                            .font(.lepca(15))
                            .fontWeight(.semibold)
                            .foregroundStyle(Color.brightGreen)
                            .multilineTextAlignment(.center)
                            .lineLimit(2)
                            .minimumScaleFactor(0.7)
                            .frame(height: 36)
                        
                        Color.clear
                            .frame(height: 10)
                    }
                    .padding(.vertical, 10)
                    .padding(.horizontal, 8)
                    .background(Color.cream.opacity(0.95))
                    .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                    .overlay {
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .stroke(Color.softStroke, lineWidth: 1)
                    }
                }
            }
        }
        .padding()
        .background(Color.canvas.opacity(0.96))
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(Color.softStroke, lineWidth: 1)
        }
        .shadow(color: Color.brightPeony.opacity(0.25), radius: 16, x: 0, y: 8)
        .overlay(alignment: .topTrailing) {
            MattePlusButton(
                size: 45,
                action: {
                    withAnimation {
                        closeAction()
                    }
                },
                pic: "xmark"
            )
                .padding(3)
                .scaleEffect(0.8)
        }
    }
}

struct PonchiAddOverlay: View {
    
    let items: [Ponchi]
    
    @Binding var selectedIndex: Int?
    var animationNamespace: Namespace.ID

    var body: some View {
        if let index = selectedIndex {
            ZStack {
                Color.black.opacity(0.5)
                    .ignoresSafeArea()
                    .onTapGesture {
                        withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                            selectedIndex = nil
                        }
                    }

                Image(items[index].image)
                    .resizable()
                    .scaledToFill()
                    .matchedGeometryEffect(id: index, in: animationNamespace)
                    .ignoresSafeArea()
                    .onTapGesture {
                        withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                            selectedIndex = nil
                        }
                    }

                VStack {
                    HStack {
                        Spacer()
                        Button {
                            withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                                selectedIndex = nil
                            }
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .font(.system(size: 30))
                                .foregroundColor(.white)
                                .padding()
                        }
                    }
                    Spacer()
                }
            }
            .transition(.opacity)
        }
    }
}


struct PonchiAddContainer: View {
    
    let items: [Ponchi]

    @Binding var selectedIndex: Int?
    @Namespace private var animationNamespace
    var cartAction: () -> Void
    var plusAction: (Ponchi) -> Void
    var closeAction: () -> Void

    var body: some View {
        ZStack(alignment: .bottom) {
            
            VStack {
                Spacer()
                
                PonchiAddView(
                    items: items, selectedIndex: $selectedIndex,
                    animationNamespace: animationNamespace,
                    cartAction: cartAction,
                    plusAction: plusAction,
                    closeAction: closeAction
                )
                .padding(.bottom, -40)
            }
            PonchiAddOverlay(
                items: items, selectedIndex: $selectedIndex,
                animationNamespace: animationNamespace
            )
        }
        .transition(.opacity)
    }
}

#Preview {
    PonchiCustomTabBar()
        .environmentObject(PreviewFactory.makePonchiViewModel())
        .environmentObject(Cart())
        .environmentObject(PreviewFactory.makeUserViewModel())
}

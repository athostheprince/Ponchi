//
//  PonCustomSegmentPicker.swift
//  Ponchi
//
//  Created by mary romanova on 05.12.2024.
//

import SwiftUI

struct SegmentItemView: View {
    
    let title: String
    let isSelected: Bool
    let animationNamespace: Namespace.ID
    let onTap: () -> Void
    let color = Color(hex: "#F4C7C3")

    var body: some View {
        Text(title)
            .bold()
            .padding(.vertical, 10)
            .padding(.horizontal, 20)
            .background(
                ZStack {
                    if isSelected {
                        RoundedRectangle(cornerRadius: 25)
                            .fill(Color.brightGreen)
                            .matchedGeometryEffect(id: "segment", in: animationNamespace)
                    }
                }
            )
            .foregroundColor(isSelected ? .peony : .secondary)
            .onTapGesture {
                HapticManager.tap()
                onTap()
            }
    }
}


struct PonCustomSegmentPicker: View {
    
    @Namespace private var animationNamespace
    
    let categories: [Category]
    @Binding var selectedCategory: Category?
    @Binding var selectedIndex: Int
    let color = Color(hex: "#F4C7C3")
    

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 0) {
                    ForEach(categories, id: \.self) { category in
                        SegmentItemView(
                            title: category.rawValue,
                            isSelected: selectedCategory == category,
                            animationNamespace: animationNamespace
                        ) {
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.6, blendDuration: 0.5)) {
                                selectedCategory = category
                            }
                        }
                        .id(category)
                    }
                }
                .padding(.horizontal)
            }
            .onAppear {
                if let selectedCategory {
                    DispatchQueue.main.async {
                        withAnimation {
                            proxy.scrollTo(selectedCategory, anchor: .center)
                        }
                    }
                }
            }
            .onChange(of: selectedCategory) { oldValue, newValue in
                guard let newValue else { return }
                HapticManager.scroll()
                withAnimation {
                    proxy.scrollTo(newValue, anchor: .center)
                }
            }
        }
    }
}

struct CustomSegmentPicker: View {
    
    @EnvironmentObject var ponchiViewModel: PonchiViewModel
    @Namespace private var animationNamespace
    
    let categories: [Size]
    let color = Color(hex: "#F4C7C3")
    
    var body: some View {
       
        HStack(alignment: .center) {
            ForEach(ponchiViewModel.availableSizes, id: \.self) { size in
                SegmentItemView(
                    title: size.rawValue,
                    isSelected: ponchiViewModel.selectedSize == size,
                    animationNamespace: animationNamespace
                ) {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.6, blendDuration: 0.5)) {
                        ponchiViewModel.selectSize(size)
                    }
                }
                .id(size)
            }
        }
        .background(Color.peony)
        .cornerRadius(20)
    }
}



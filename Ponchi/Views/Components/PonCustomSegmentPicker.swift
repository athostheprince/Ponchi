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
            .padding(.vertical, 10)
            .padding(.horizontal, 20)
            .background(
                ZStack {
                    if isSelected {
                        RoundedRectangle(cornerRadius: 25)
                            .fill(color)
                            .matchedGeometryEffect(id: "segment", in: animationNamespace)
                    }
                }
            )
            .foregroundColor(isSelected ? .white : Color(hex: "#F99CA0"))
            .onTapGesture {
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
                                proxy.scrollTo(category, anchor: .top)
                            }
                        }
                        .id(category)
                    }
                }
                .padding(.horizontal)
            }
            .onChange(of: selectedCategory) { oldValue, newValue in
                guard let newValue else { return }
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
        .background(color)
        .cornerRadius(20)
    }
}

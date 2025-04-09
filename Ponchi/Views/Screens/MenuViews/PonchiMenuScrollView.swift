//
//  PonchiMenuScrollView.swift
//  Ponchi
//
//  Created by mary romanova on 16.12.2024.
//

import SwiftUI

struct PonchiMenuScrollView: View {
    
    @EnvironmentObject var ponchiViewModel: PonchiViewModel
    @Binding var selectedCategory: Category?
    @Binding var selectedIndex: Int
    
    let categories = Category.allCases
    var columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    private func isCategoryVisible(_ geometry: GeometryProxy) -> Bool {
        let frame = geometry.frame(in: .global)
        let screenHeight = UIScreen.main.bounds.height
        return frame.minY < screenHeight * 0.8 && frame.maxY > screenHeight * 0.2
    }
    
    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVGrid(columns: columns, spacing: 10) {
                    ForEach(categories, id: \.self) { category in
                        Section(header: Text(category.rawValue)
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundStyle(.white)
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                        ) {
                            ForEach(ponchiViewModel.getProducts(for: category.rawValue)) { product in
                                PonClassicSectionView(product: product)
                                    .onTapGesture {
                                        withAnimation {
                                            ponchiViewModel.isShowingDetails.toggle()
                                            ponchiViewModel.selectedPonchi = product
                                        }
                                    }
                            }
                        }
                        .background(
                            GeometryReader { geometry in
                                Color.clear
                                    .preference(
                                        key: SectionPositionPreferenceKey.self,
                                        value: geometry.frame(in: .global).minY < UIScreen.main.bounds.height / 2 ? category : nil
                                    )
                            }
                        )
                        .id(category) // Уникальный идентификатор для прокрутки
                    }
                }
                .onChange(of: selectedCategory) { oldValue, newValue in
                    withAnimation {
                        if let newCategory = newValue {
                            proxy.scrollTo(newCategory, anchor: .top) // Прокрутка к выбранной категории
                        }
                    }
                }
                .padding(.horizontal)
            }
            .padding(.vertical)
            .background(Color(hex: "#4e6d54"))
            .cornerRadius(20)
            .ignoresSafeArea()
            .onPreferenceChange(SectionPositionPreferenceKey.self) { newCategory in
                withAnimation {
                    if let newCategory, newCategory != selectedCategory {
                        selectedCategory = newCategory
                        proxy.scrollTo(selectedCategory, anchor: .top)
                    }
                }
            }
            .onAppear {
                selectedIndex = 0
                selectedCategory = categories.first
            }
        }
    }
}

//
//  PonchiToppingsView.swift
//  Ponchi
//
//  Created by mary romanova on 21.12.2024.
//

import SwiftUI

struct PonchiToppingsView: View {
    @EnvironmentObject var viewModel: PonchiViewModel
    
    var body: some View {
        VStack {
            if let availableToppings = viewModel.availableToppings {
                ForEach(availableToppings) { category in
                    Menu {
                        ForEach(category.options) { option in
                            Button(action: {
                                viewModel.toggleToppingSelection(for: option, in: category)
                            }) {
                                HStack {
                                    Text(option.name)
                                    Spacer()
                                    if option.isSelected {
                                        Image(systemName: "checkmark")
                                            .foregroundColor(.green)
                                    } else {
                                        Image(systemName: "plus")
                                            .foregroundColor(.gray)
                                    }
                                }
                            }
                        }
                    } label: {
                        HStack {
                            Text(category.category.rawValue)
                            Spacer()
                            // Показывает выбранный вариант
                            if let selectedOption = category.options.first(where: { $0.isSelected }) {
                                Text(selectedOption.name)
                                    .foregroundColor(Color("brandColor"))
                                Image(systemName: "checkmark")
                                    .foregroundColor(Color("brandColor"))
                            } else {
                                Text("Выбрать")
                                    .foregroundColor(.gray)
                                Image(systemName: "plus")
                                    .foregroundColor(.gray)
                            }
                        }
                        .foregroundColor(category.options.contains(where: { $0.isSelected }) ? Color("brandColor") : .gray)
                    }
                    Divider()
                }
            }
        }
    }
}

#Preview {
    PonchiMenuView()
        .environmentObject(PonchiViewModel())
}

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
        VStack(spacing: 12) {
            if let availableToppings = viewModel.availableToppings {
                ForEach(Array(availableToppings.enumerated()), id: \.element.id) { index, category in
                    Menu {
                        ForEach(category.options) { option in
                            Button(action: {
                                viewModel.toggleToppingSelection(for: option, in: category)
                            }) {
                                HStack {
                                    Text(option.name)

                                    Spacer()
                                    if option.isSelected {
                                        Image(systemName: "checkmark.circle.fill")
                                            .foregroundColor(.brightGreen)
                                    } else {
                                        Image(systemName: "plus.circle")
                                            .foregroundColor(Color.brightGreen.opacity(0.45))
                                    }
                                }
                            }
                        }
                    } label: {
                        HStack {
                            Text(category.category.rawValue)
                                .font(.caviarb(18))
                            Spacer()

                            if let selectedOption = category.options.first(where: { $0.isSelected }) {
                                Text(selectedOption.name)
                                    .font(.caviarb(16))
                                    .foregroundColor(.brightGreen)
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.brightGreen)
                            } else {
                                Text("Выбрать")
                                    .font(.caviarb(16))
                                    .foregroundColor(Color.brightGreen.opacity(0.55))
                                Image(systemName: "plus.circle")
                                    .foregroundColor(Color.brightGreen.opacity(0.45))
                            }
                        }
                        .foregroundColor(category.options.contains(where: { $0.isSelected }) ? .brightGreen : Color.brightGreen.opacity(0.75))
                        .padding(.vertical, 4)
                    }
                    if index < availableToppings.count - 1 {
                        Divider()
                            .overlay(Color.softStroke)
                    }
                }
            }
        }
    }
}

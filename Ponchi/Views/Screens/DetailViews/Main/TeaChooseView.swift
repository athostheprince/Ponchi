//
//  TeaChooseView.swift
//  Ponchi
//
//  Created by mary romanova on 11.12.2025.
//

import SwiftUI

struct TeaChooseView: View {
    
    let teaType: [TeaType]
    @Binding var selectedTea: TeaType
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(teaType) { tea in
                    Button {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            selectedTea = tea
                        }
                    } label: {
                        Text(tea.rawValue)
                            .font(.caviarb(18))
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .foregroundStyle(selectedTea == tea ? Color.peony : Color.brightGreen)
                            .background {
                                Capsule()
                                    .fill(selectedTea == tea ? Color.brightGreen : Color.cream.opacity(0.96))
                            }
                            .overlay {
                                Capsule()
                                    .stroke(selectedTea == tea ? Color.brightGreen : Color.softStroke, lineWidth: 1)
                            }
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 4)
        }
    }
}

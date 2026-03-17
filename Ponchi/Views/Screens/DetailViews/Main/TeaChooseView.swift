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
            HStack {
                ForEach(teaType) { tea in
                    ZStack {
                        Capsule()
                            .fill(selectedTea == tea ? Color.brightPeony: Color.clear)
                            .stroke(Color.brightPeony, lineWidth: 3)
                            .frame(height: 30)
                        
                        Text(tea.rawValue)
                            .font(.caviarb(18))
                            .padding(.horizontal)
                            .foregroundStyle(selectedTea == tea ? Color.white : Color.brightPeony)
                    }
                    .onTapGesture {
                        withAnimation {
                            selectedTea = tea
                        }
                    }
                }
                
            }
            .padding()
        }
    }
}

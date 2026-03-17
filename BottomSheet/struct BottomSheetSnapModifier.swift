//
//  SwiftUIView.swift
//  Ponchi
//
//  Created by mary romanova on 16.01.2026.
//

import SwiftUI

struct BottomSheetSnapModifier: ViewModifier {
    
    @Binding var position: BottomSheetPosition
    
    let collapsedOffset: BottomSheetPosition
    let expendedOffset: BottomSheetPosition
    
    @GestureState private var hasMoved = false
    
    @State private var lastPosition: BottomSheetPosition?
    
    func body(content: Content) -> some View {
        content
            .gesture(
                DragGesture(minimumDistance: 0.3)
                    .updating($hasMoved, body: { value, state, _ in
                        state = true
                    })
                    .onChanged { value in
                        
                        if value.translation.height < 0 {
                            withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
                                position = expendedOffset
                                HapticManager.mediumTab()
                            }
                        } else if value.translation.height > 0 {
                            withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
                                position = collapsedOffset
                                HapticManager.mediumTab()
                                
                            }
                        }
                    }
            )
    }
    
}

extension View {
    func bottomSheetSnap(
        position: Binding<BottomSheetPosition>,
        collapsed: BottomSheetPosition,
        expanded: BottomSheetPosition
    ) -> some View {
        self.modifier(
            BottomSheetSnapModifier(position: position, collapsedOffset: collapsed, expendedOffset: expanded)
        )
    }
}

//
//  CustomPullToRefresh.swift
//  Ponchi
//
//  Created by mary romanova on 12.02.2026.
//

import SwiftUI

struct PullOffsetKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = max(value, nextValue())
    }
}

struct CustomPullToRefresh<Content: View>: View {
    
    @State private var isRefreshing = false
    @State private var pullOffset: CGFloat = 0
    
    let onRefresh: () async -> Void
    let content: Content
    
    init(onRefresh: @escaping () async -> Void, @ViewBuilder content: () -> Content) {
        self.onRefresh = onRefresh
        self.content = content()
    }
    
    var body: some View {
        ScrollView {
            GeometryReader { geo in
                Color.clear
                    .preference(key: PullOffsetKey.self, value: geo.frame(in: .named("scroll")).minY)
            }
            .frame(height: 0)

            let isActive = pullOffset > 0 || isRefreshing
            let height = isActive ? min(pullOffset, 80) : 0

            VStack {
                Image("coffeeToGo")
                    .renderingMode(.template)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 32, height: 32)
                    .foregroundStyle(Color.brightGreen)
                    .rotationEffect(.degrees(isRefreshing ? 360 : pullOffset * 3))
                    .opacity(isActive ? 1 : 0)
                    .scaleEffect(isActive ? 1 : 0.85)
                    .animation(.easeOut(duration: 0.2), value: pullOffset)
            }
            .frame(height: height)

            content
        }
        .coordinateSpace(name: "scroll")
        .onPreferenceChange(PullOffsetKey.self) { value in
            let offset = max(0, value)
            pullOffset = offset

            if offset > 80 && !isRefreshing {
                isRefreshing = true
                Task {
                    await onRefresh()
                    isRefreshing = false
                    pullOffset = 0
                }
            }
        }
    }

    private var indicatorHeight: CGFloat {
        min(pullOffset, 80)
    }
}

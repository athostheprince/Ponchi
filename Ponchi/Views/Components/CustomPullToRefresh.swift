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
            let progress = min(max(pullOffset / 80, 0), 1)
            let height = isActive ? min(pullOffset, 80) : 0

            VStack {
                ZStack {
                    Circle()
                        .stroke(Color.brightGreen.opacity(0.16), lineWidth: 2)

                    Circle()
                        .trim(from: 0.18, to: isRefreshing ? 0.82 : 0.18 + 0.64 * progress)
                        .stroke(
                            Color.brightGreen,
                            style: StrokeStyle(lineWidth: 2.5, lineCap: .round)
                        )
                        .rotationEffect(.degrees(isRefreshing ? 360 : Double(progress) * 220))
                        .animation(
                            isRefreshing
                                ? .linear(duration: 0.85).repeatForever(autoreverses: false)
                                : .easeOut(duration: 0.2),
                            value: isRefreshing
                        )
                        .animation(.easeOut(duration: 0.2), value: progress)
                }
                .frame(width: 28, height: 28)
                .opacity(isActive ? 1 : 0)
                .scaleEffect(0.9 + 0.1 * progress)
            }
            .frame(maxWidth: .infinity)
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

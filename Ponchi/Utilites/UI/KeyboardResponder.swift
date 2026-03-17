//
//  KeyboardResponder.swift
//  Ponchi
//
//  Created by mary romanova on 25.11.2025.
//

import Foundation
import SwiftUI
import Combine

final class KeyboardResponder: ObservableObject {
    @Published var currentHeight: CGFloat = 0
    private var cancellables = Set<AnyCancellable>()

    init() {
        let willShow = NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)
            .compactMap { $0.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect }
            .map { $0.height }

        let willHide = NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)
            .map { _ in CGFloat.zero }

        Publishers.Merge(willShow, willHide)
            .assign(to: \.currentHeight, on: self)
            .store(in: &cancellables)
    }
}

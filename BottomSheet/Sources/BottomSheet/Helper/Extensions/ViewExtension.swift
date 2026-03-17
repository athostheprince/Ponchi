//
//  ViewExtension.swift
//
//
//  Created by Jukka Hietanen on 12.12.2023.
//

import Foundation

import SwiftUI
import Combine

internal extension View {
    @ViewBuilder
    func valueChanged<T: Equatable>(
        value: T,
        onChange: @escaping (T) -> Void
    ) -> some View {
        if #available(iOS 17.0, macOS 14.0, *) {
            self.onChange(of: value) { _, newValue in
                onChange(newValue)
            }
//        } else if {
//            self.onChange(of: value) { newValue in
//                onChange(newValue)
//            }
        } else {
            self.onReceive(
                Just(value).removeDuplicates()
            ) { value in
                onChange(value)
            }
        }
    }
}

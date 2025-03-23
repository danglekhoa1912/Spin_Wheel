//
//  ListBackgroundModifier.swift
//  WheelSpinApp
//
//  Created by Dang Khoa Dang Le on 23/03/2025.
//

import Foundation
import SwiftUICore

struct ListBackgroundModifier: ViewModifier {

    @ViewBuilder
    func body(content: Content) -> some View {
        if #available(iOS 16.0, *) {
            content
                .scrollContentBackground(.hidden)
        } else {
            content
        }
    }
}

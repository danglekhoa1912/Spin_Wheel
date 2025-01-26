//
//  WSButton.swift
//  WheelSpinApp
//
//  Created by Dang Khoa Dang Le on 27/01/2025.
//

import SwiftUI

struct WSButton: View {
    var title: String
    var action: () -> ()
    var buttonColor: Color = .primary

    var body: some View {
        Button {
            action()
        } label: {
            ZStack {
                RoundedRectangle(cornerRadius: 20)
                    .foregroundColor(buttonColor)
                    .frame(minWidth: 0, maxWidth: .infinity)

                Text(title)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
                    .padding()
            }
            .fixedSize()
        }
    }
}

#Preview {
    WSButton(title: "Click", action: {})
}

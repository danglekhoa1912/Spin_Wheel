//
//  CircleButton.swift
//  WheelSpinApp
//
//  Created by Dang Khoa Dang Le on 27/01/2025.
//

import SwiftUI

struct CircleButton: View {
    let iconName: String
    var body: some View {
        Image(systemName: iconName)
            .font(.headline)
            .foregroundColor(.black)
            .frame(width: 50, height: 50)
            .background(
                Circle()
                    .foregroundColor(.white)
            )
            .shadow(color: Color(.black).opacity(0.25), radius: 10, x: 0, y: 0)
            .padding()
    }
}

#Preview {
    CircleButton(iconName: "chevron.left")
}

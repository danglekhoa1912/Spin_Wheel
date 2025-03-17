//
//  SpinWheelListView.swift
//  WheelSpinApp
//
//  Created by Dang Khoa Dang Le on 28/01/2025.
//

import SwiftUI

struct SpinWheelListView: View {
    var body: some View {
        VStack {
            HStack {
                Button {
//                    dismiss()
                } label: {
                    CircleButton(iconName: "chevron.left")
                }
                Spacer()
                Text("Spin")
                    .font(.title2)
                    .bold()
                Spacer()
                Button {

                } label: {
                    CircleButton(iconName: "gearshape")
                }
            }
            Spacer()
        }
        .padding()
        .background(
            LinearGradient(colors: [Color(hex: "#8EC5FC"), Color(hex: "#E0C3FC")], startPoint: .bottomLeading, endPoint: .topTrailing)
        )
        .navigationBarHidden(true)
    }
}

#Preview {
    SpinWheelListView()
}

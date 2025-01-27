//
//  HomeView.swift
//  WheelSpinApp
//
//  Created by Dang Khoa Dang Le on 27/01/2025.
//

import SwiftUI

struct HomeView: View {
    var body: some View {
        VStack(spacing: 30) {
            RoundedRectangle(cornerRadius: 20)
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color.primary, Color.primary.opacity(0.6),
                        ]), startPoint: .topLeading, endPoint: .bottomTrailing)
                )
                .frame(height: 180)
                .overlay {
                    HStack {
                        VStack(alignment: .leading) {
                            Text("Win everyday")
                                .font(.title2)
                                .bold()
                                .foregroundColor(.white)
                            NavigationLink {
                                WheelView()
                            } label: {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 20)
                                        .foregroundColor(Color.secondary)
                                        .frame(minWidth: 0, maxWidth: .infinity)

                                    Text("Spin now")
                                        .font(.system(size: 16, weight: .bold))
                                        .foregroundColor(.white)
                                        .padding()
                                }
                                .fixedSize()
                            }
                        }
                        Spacer()
                        Image(name: .logoApp)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 100, height: 100)
                    }
                    .padding()
                }

            VStack {
                HStack {
                    Text("Spin saved")
                        .font(.title2)
                        .fontWeight(.semibold)
                    Spacer()
                    Button {

                    } label: {
                        Text("Show all")
                    }
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
    HomeView()
}

//
//  HomeView.swift
//  WheelSpinApp
//
//  Created by Dang Khoa Dang Le on 27/01/2025.
//

import SwiftUI

struct HomeView: View {
    @State var showCreateSpinWheel = false
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            VStack(spacing: 30) {
                RoundedRectangle(cornerRadius: 20)
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color.primary, Color.primary.opacity(0.6),
                            ]), startPoint: .topLeading,
                            endPoint: .bottomTrailing)
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
                                            .frame(
                                                minWidth: 0, maxWidth: .infinity
                                            )

                                        Text("Spin now")
                                            .font(
                                                .system(size: 16, weight: .bold)
                                            )
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

                    RoundedRectangle(cornerRadius: 20)
                        .fill(.white)
                        .frame(height: 100)
                        .shadow(radius: 6)
                        .overlay {
                            HStack {
                                VStack(alignment: .leading, spacing: 10) {
                                    Text("What to eat ?")
                                        .font(.title3)
                                        .fontWeight(.semibold)
                                    Text("Spins: 2")
                                        .font(.caption)
                                        .fontWeight(.thin)
                                }

                                Spacer()

                                Menu {

                                    Button(action: {}) {
                                        SwiftUI.Label(
                                            "Edit",
                                            systemImage:
                                                "square.and.pencil")
                                    }

                                    Button(action: {}) {
                                        SwiftUI.Label(
                                            "Share",
                                            systemImage: "arrowshape.turn.up.right.fill")
                                    }

                                    Button(role: .destructive, action: {}) {
                                        SwiftUI.Label(
                                            "Delete", systemImage: "trash")
                                    }

                                } label: {
                                    Image(systemName: "ellipsis.circle")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 20, height: 20)
                                        .tint(.black)
                                }

                            }
                            .hSpacing(.leading)
                            .padding()
                        }

                }
                Spacer()
            }
            Button {
                showCreateSpinWheel = true
            } label: {
                Image(systemName: "plus")
                    .fontWeight(.semibold)
                    .foregroundStyle(.white)
                    .frame(width: 55, height: 55)
                    .background(
                        Color.primary.shadow(
                            .drop(
                                color: .black.opacity(0.25), radius: 5, x: 10,
                                y: 10)), in: .circle)
            }
        }

        .padding()
        .background(
            LinearGradient(
                colors: [Color(hex: "#8EC5FC"), Color(hex: "#E0C3FC")],
                startPoint: .bottomLeading, endPoint: .topTrailing)
        )
        .navigationBarHidden(true)
        .sheet(
            isPresented: $showCreateSpinWheel,
            content: {
                NewSpinWheelView()
                    .interactiveDismissDisabled()
                    .presentationCornerRadius(30)
                    .presentationBackground(.white)
            })
    }
}

#Preview {
    HomeView()
}

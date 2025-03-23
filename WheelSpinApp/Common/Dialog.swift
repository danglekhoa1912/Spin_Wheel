//
//  Dialog.swift
//  WheelSpinApp
//
//  Created by Dang Khoa Dang Le on 26/01/2025.
//

import SwiftUI

struct Dialog: View {
    @Binding var isPresented: Bool
    let title: String
    let message: String
    let primaryButtonTitle: String
    let primaryButtunAction: () -> Void
    let secondaryButtonTitle: String?
    let secondaryButtunAction: (() -> Void)?

    @State private var offset: CGFloat = 1000

    var body: some View {
        ZStack {
            Color(.black)
                .opacity(0.5)
                .onTapGesture {
                    close()
                }

            VStack {
                Text(title)
                    .foregroundColor(.black)
                    .font(.title2)
                    .bold()
                    .padding()

                Text(message)
                    .foregroundColor(.black)
                    .font(.body)

                HStack {
                    Button {
                        primaryButtunAction()
                        close()
                    } label: {
                        ZStack {
                            RoundedRectangle(cornerRadius: 20)
                                .foregroundColor(
                                    secondaryButtonTitle != nil
                                        ? .gray : .primary)

                            Text(primaryButtonTitle)
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.white)
                                .padding()
                        }
                        .padding()
                    }
                    if secondaryButtonTitle != nil {
                        Button {
                            secondaryButtunAction?()
                            close()
                        } label: {
                            ZStack {
                                RoundedRectangle(cornerRadius: 20)
                                    .foregroundColor(.primary)

                                Text(secondaryButtonTitle!)
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(.white)
                                    .padding()
                            }
                            .padding()
                        }
                    }
                }
            }
            .fixedSize(horizontal: false, vertical: true)
            .padding()
            .background(.white)
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .overlay {
                VStack {
                    HStack {
                        Spacer()
                        Button {
                            close()
                        } label: {
                            Image(systemName: "xmark")
                                .font(.system(size: 22, weight: .medium))
                        }
                        .tint(.black)
                    }
                    Spacer()
                }
                .padding()
            }
            .shadow(radius: 20)
            .padding(30)
            .offset(x: 0, y: offset)
            .onAppear {
                withAnimation(.spring) {
                    offset = 0
                }
            }
        }
        .ignoresSafeArea()
    }

    func close() {
        isPresented = false
        withAnimation(.spring) {
            offset = 1000
        }
    }
}

#Preview {
    Dialog(
        isPresented: .constant(true), title: "We have Winner!",
        message: "The winner is Khoa", primaryButtonTitle: "Close",
        primaryButtunAction: {}, secondaryButtonTitle: "Remove",
        secondaryButtunAction: {})
}

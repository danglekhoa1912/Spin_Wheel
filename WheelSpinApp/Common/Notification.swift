//
//  Notification.swift
//  WheelSpinApp
//
//  Created by Dang Khoa Dang Le on 04/04/2025.
//

import SwiftUI

struct Notification: View {
    @ObservedObject var manager = NotificationManager.shared
    var body: some View {
        VStack {
            if manager.isShowing, let message = manager.currentNotification {
                HStack {
                    Image(
                        systemName: message.isError
                            ? "exclamationmark.triangle.fill"
                            : "checkmark.circle.fill"
                    )
                    .foregroundColor(message.isError ? .red : .green)
                    Text(message.title)
                        .foregroundColor(.white)
                        .font(.system(size: 16, weight: .medium))
                    Spacer()
                }
                .padding()
                .background(
                    message.isError
                        ? Color.red.opacity(0.8) : Color.green.opacity(0.8)
                )
                .cornerRadius(10)
                .shadow(radius: 5)
                .padding(.horizontal)
                .padding(.top, 50)
                .transition(.move(edge: .top).combined(with: .opacity))
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                        withAnimation {
                            self.manager.isShowing = false
                        }
                    }
                }
            }
            Spacer()
        }
    }
}

#Preview {
    Group {
        Notification()
        Notification()
    }
}

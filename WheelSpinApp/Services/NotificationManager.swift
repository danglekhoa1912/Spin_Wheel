//
//  NotificationManager.swift
//  WheelSpinApp
//
//  Created by Dang Khoa Dang Le on 04/04/2025.
//

import Foundation
import SwiftUI

class NotificationManager: ObservableObject {
    static let shared = NotificationManager()
    @Published var currentNotification: NotificationMessage? = nil
    @Published var isShowing: Bool = false

    private init() {}

    func showNotification(title: String, isError: Bool) {
        let notification = NotificationMessage(title: title, isError: isError)
        DispatchQueue.main.async {
            withAnimation {
                self.currentNotification = notification
                self.isShowing = true
            }
        }
    }
}

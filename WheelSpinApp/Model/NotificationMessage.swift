//
//  NotificationMessage.swift
//  WheelSpinApp
//
//  Created by Dang Khoa Dang Le on 04/04/2025.
//

import Foundation

struct NotificationMessage: Identifiable {
    let id = UUID()
    let title: String
    let isError: Bool
}

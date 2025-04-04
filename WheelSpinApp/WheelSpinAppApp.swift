//
//  WheelSpinAppApp.swift
//  WheelSpinApp
//
//  Created by Dang Khoa Dang Le on 26/01/2025.
//

import SwiftUI
import FirebaseCore


@main
struct WheelSpinAppApp: App {
    init() {
        FirebaseApp.configure()
    }
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

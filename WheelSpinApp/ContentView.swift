//
//  ContentView.swift
//  WheelSpinApp
//
//  Created by Dang Khoa Dang Le on 26/01/2025.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject private var spinWheelsTable = SpinWheelsTable.shared

    var body: some View {
        Group {
            if #available(iOS 16.0, *) {
                NavigationStack {
                    HomeView()
                        .onOpenURL { url in
                            handleURL(url)
                        }
                }
            } else {
                NavigationView {
                    HomeView()
                        .onOpenURL { url in
                            handleURL(url)
                        }
                }
            }
        }
        .overlay(alignment: .top) {
            Notification()
        }

    }

    private func handleURL(_ url: URL) {
        guard url.scheme == "wheelspinapp",
            url.host == "share",
            let components = URLComponents(
                url: url, resolvingAgainstBaseURL: false),
            let queryItems = components.queryItems,
            let code = queryItems.first(where: { $0.name == "code" })?.value
        else {
            print("❌ URL không hợp lệ: \(url)")
            return
        }

        Task {
            await spinWheelsTable.addSpinWheelFromShareCode(code: code)
            //            await vm.addSpinWheelFromShareCode(code)
            print("✅ Đã xử lý URL với mã: \(code)")
        }
    }
}

#Preview {
    ContentView()
}

//
//  ContentView.swift
//  WheelSpinApp
//
//  Created by Dang Khoa Dang Le on 26/01/2025.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        if #available(iOS 16.0, *) {
            NavigationStack {
                HomeView()
            }
        } else {
            NavigationView {
                HomeView()
            }
        }
        
    }
}

#Preview {
    ContentView()
}

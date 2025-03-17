//
//  HomeViewModel.swift
//  WheelSpinApp
//
//  Created by Dang Khoa Dang Le on 29/01/2025.
//

import Foundation

class HomeViewModel: ObservableObject {
    @Published var spinWheelList: [SpinWheel] = []

    func loadData() async {
        let data = await SpinWheelsTable.shared.getSpinWheels()
        DispatchQueue.main.async {
            self.spinWheelList = data
        }
    }
}

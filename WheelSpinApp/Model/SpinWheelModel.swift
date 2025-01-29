//
//  SpinWheelModel.swift
//  WheelSpinApp
//
//  Created by Dang Khoa Dang Le on 28/01/2025.
//

import Foundation

struct Label: Identifiable {
    let id = UUID()
    let value: String
}

class SpinWheelModel: ObservableObject {
    @Published var labels: [Label] = []
    @Published var title: String = ""
    @Published var newLabel: String = ""
    
    var isValid: Bool {
        return !title.isEmpty && !labels.isEmpty
    }
    
    func addNewLabel() {
        labels.append(Label(value: newLabel))
        newLabel = ""
    }
    
    func deleteLabel(at offset: IndexSet) {
        labels.remove(atOffsets: offset)
    }
    
    func createSpinWheel() {
        let result = SpinWheelsTable.shared.createSpinWheel(spinWheel: SpinWheel(title: title, labels: labels.map({$0.value})))
        print(result)
    }
}

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
    @Published var id: String? = ""

    let notification = NotificationManager.shared

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

    func createSpinWheel() async {
        let result = await SpinWheelsTable.shared.createSpinWheel(
            spinWheel: SpinWheel(title: title, labels: labels.map({ $0.value }))
        )
        if result != 0 {
            notification.showNotification(title: "create wheel successfully", isError: false)
        } else {
            notification.showNotification(title: "create wheel failed", isError: false)
        }
    }

    func updateSpinWheel() async {
        if id != nil {
            let result = await SpinWheelsTable.shared.updateSpinWheel(
                spinWheel: SpinWheel(
                    id: id!, shareCode: "", title: title,
                    labels: labels.map({ $0.value }), isUploadToServer: false))
            if result != nil {
                notification.showNotification(title: "update wheel successfully", isError: false)
            } else {
                notification.showNotification(title: "update wheel failed", isError: false)
            }
        }
    }
}

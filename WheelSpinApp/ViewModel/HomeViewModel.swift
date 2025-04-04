//
//  HomeViewModel.swift
//  WheelSpinApp
//
//  Created by Dang Khoa Dang Le on 29/01/2025.
//

import Foundation

class HomeViewModel: ObservableObject {

    @Published var showingShareSheet: Bool = false
    @Published var shareItems: [Any] = []

    func shareWheel(spinWheel: SpinWheel, documentId: String) {
        let shareURL = URL(
            string: "wheelspinapp://share?code=\(documentId)")!
        let shareMessage =
            "Nhấn link để thêm vòng quay '\(spinWheel.title)' vào WheelSpinApp: \(shareURL.absoluteString)"
        shareItems = [shareMessage, shareURL]
        showingShareSheet = true
    }
}

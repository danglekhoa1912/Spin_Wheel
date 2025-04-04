//
//  QRScannerDelegate.swift
//  WheelSpinApp
//
//  Created by Dang Khoa Dang Le on 30/03/2025.
//

import Foundation
import AVKit

class QRScannerDelegate: NSObject, ObservableObject, AVCaptureMetadataOutputObjectsDelegate {
    @Published var scannedCode: String?
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        if let metaObject = metadataObjects.first {
            guard let readableObject = metaObject as? AVMetadataMachineReadableCodeObject else { return }
            guard let scannerCode = readableObject.stringValue else { return }
            scannedCode = scannerCode
        }
    }
}

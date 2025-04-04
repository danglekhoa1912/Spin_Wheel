//
//  CameraView.swift
//  WheelSpinApp
//
//  Created by Dang Khoa Dang Le on 30/03/2025.
//

import AVKit
import SwiftUI

struct CameraView: UIViewRepresentable {
    var frameSize: CGSize

    @Binding var session: AVCaptureSession
    func makeUIView(context: Context) -> UIView {
        let view = UIViewType(frame: CGRect(origin: .zero, size: frameSize))
        view.backgroundColor = .clear
        let cameraPlayer = AVCaptureVideoPreviewLayer(session: session)
        cameraPlayer.frame = .init(origin: .zero, size: frameSize)
        cameraPlayer.videoGravity = .resizeAspectFill
        cameraPlayer.masksToBounds = true
        view.layer.addSublayer(cameraPlayer)

        return view
    }

    func updateUIView(_ uiView: UIViewType, context: Context) {
        if let layer = uiView.layer.sublayers?.first
            as? AVCaptureVideoPreviewLayer
        {
            layer.frame = CGRect(origin: .zero, size: frameSize)
        }
    }
}

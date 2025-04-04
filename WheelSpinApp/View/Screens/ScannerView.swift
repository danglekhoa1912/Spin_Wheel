//
//  ScannerView.swift
//  WheelSpinApp
//
//  Created by Dang Khoa Dang Le on 30/03/2025.
//

import AVKit
import SwiftUI

struct ScannerView: View {
    @State private var isScanning: Bool = false
    @State private var session: AVCaptureSession = .init()
    @State private var cameraPermission: Permission = .idle
    @Environment(\.dismiss) private var dismiss

    @State private var qrOutput: AVCaptureMetadataOutput = .init()

    @State private var errorMessage: String = ""
    @State private var showError: Bool = false
    @State private var scannedCode: String = ""
    @Environment(\.openURL) private var openURL

    @ObservedObject private var spinWheelsTable = SpinWheelsTable.shared
    @StateObject private var qrDelegate = QRScannerDelegate()
    var body: some View {
        VStack(spacing: 8) {
            Button {
                session.stopRunning()
                dismiss()
            } label: {
                Image(systemName: "xmark")
                    .font(.title3)
                    .foregroundColor(.blue)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal)

            Text("Place the QR code inside the area")
                .font(.title3)
                .foregroundColor(.black.opacity(0.8))
                .padding(.top, 20)

            Text("Scanning will start automatically")
                .font(.callout)
                .foregroundColor(.gray)

            Spacer(minLength: 0)

            GeometryReader {
                let size = $0.size
                ZStack {
                    CameraView(
                        frameSize: CGSize(
                            width: size.width, height: size.width),
                        session: $session
                    )
                    .scaleEffect(0.97)

                    ForEach(0...4, id: \.self) {
                        index in
                        let rotation = 90 * Double(index)

                        RoundedRectangle(cornerRadius: 2, style: .circular)
                            //Trimming to get Scanner like Edges
                            .trim(from: 0.61, to: 0.64)
                            .stroke(
                                Color.blue,
                                style: StrokeStyle(
                                    lineWidth: 5, lineCap: .round,
                                    lineJoin: .round)
                            )
                            .rotationEffect(.init(degrees: rotation))
                    }

                }
                //Square Shape
                .frame(width: size.width, height: size.width)
                //Scanner animation
                .overlay(alignment: .top) {
                    Rectangle()
                        .fill(.blue)
                        .frame(height: 2.5)
                        .shadow(
                            color: .black.opacity(0.8), radius: 8, x: 0,
                            y: isScanning ? 15 : -15
                        )
                        .offset(y: isScanning ? size.width : 0)
                }
                //To make it center
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .padding(.horizontal, 45)

            Spacer(minLength: 15)

            Button {
                if !session.isRunning && cameraPermission == .approved {
                    reActivateCamera()
                    activateScannerAnimation()
                }
            } label: {
                Image(systemName: "qrcode.viewfinder")
                    .font(.largeTitle)
                    .foregroundColor(.gray)
            }

            Spacer(minLength: 45)
        }
        .padding(15)
        .onAppear(perform: checkCameraPermission)
        .onDisappear {
            session.stopRunning()
        }
        .alert(errorMessage, isPresented: $showError) {
            if cameraPermission == .denied {
                Button("Settings") {
                    let settingsString = UIApplication.openSettingsURLString
                    if let settingsURL = URL(string: settingsString) {
                        openURL(settingsURL)
                    }
                }

                Button("Cancel", role: .cancel) {}
            }
        }
        .background(.white)
        .onChange(of: qrDelegate.scannedCode) {
            newValue in
            if let code = newValue {
                scannedCode = code
                session.stopRunning()
                deActivateScannerAnimation()
                qrDelegate.scannedCode = nil
                Task {
                    await spinWheelsTable.addSpinWheelFromShareCode(code: code)
                    print("✅ Đã xử lý URL với mã: \(code)")
                    dismiss()
                }
            }
        }
    }

    func reActivateCamera() {
        DispatchQueue.global(qos: .userInitiated).async {
            self.session.startRunning()
        }
    }

    func activateScannerAnimation() {
        withAnimation(
            .easeInOut(duration: 0.85).delay(0.1).repeatForever(
                autoreverses: true)
        ) {
            isScanning = true
        }
    }

    func deActivateScannerAnimation() {
        withAnimation(
            .easeInOut(duration: 0.85)
        ) {
            isScanning = false
        }
    }
    //Check camera permission
    func checkCameraPermission() {
        Task {
            switch AVCaptureDevice.authorizationStatus(for: .video) {
            case .authorized:
                cameraPermission = .approved
                if session.inputs.isEmpty {
                    setupCamera()
                } else {
                    reActivateCamera()
                }
            case .denied, .restricted:
                cameraPermission = .denied
                presentError(
                    "Please Provie Access to Camera for scanning codes")
            case .notDetermined:
                if await AVCaptureDevice.requestAccess(for: .video) {
                    cameraPermission = .approved
                    setupCamera()
                } else {
                    cameraPermission = .denied
                    presentError(
                        "Please Provie Access to Camera for scanning codes")
                }
            default: break
            }
        }
    }

    func setupCamera() {
        do {
            // Stop any existing session
            if session.isRunning {
                session.stopRunning()
            }

            // Remove any existing inputs and outputs
            session.beginConfiguration()
            session.inputs.forEach { session.removeInput($0) }
            session.outputs.forEach { session.removeOutput($0) }
            session.commitConfiguration()

            // Setup new session
            guard
                let device = AVCaptureDevice.DiscoverySession(
                    deviceTypes: [.builtInWideAngleCamera], mediaType: .video,
                    position: .back
                ).devices.first
            else {
                presentError("Camera not found")
                return
            }

            let input = try AVCaptureDeviceInput(device: device)

            guard session.canAddInput(input), session.canAddOutput(qrOutput)
            else {
                presentError("Failed to setup camera input/output")
                return
            }

            session.beginConfiguration()
            session.addInput(input)
            session.addOutput(qrOutput)

            qrOutput.metadataObjectTypes = [.qr]
            qrOutput.setMetadataObjectsDelegate(qrDelegate, queue: .main)

            session.commitConfiguration()

            // Start session on background thread
            DispatchQueue.global(qos: .userInitiated).async {
                self.session.startRunning()
                DispatchQueue.main.async {
                    self.activateScannerAnimation()
                }
            }

        } catch {
            presentError(error.localizedDescription)
        }
    }

    func presentError(_ message: String) {
        errorMessage = message
        showError = true
    }
}

#Preview {
    ScannerView()
}

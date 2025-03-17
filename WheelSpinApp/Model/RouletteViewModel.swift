//
//  RouletteViewModel.swift
//  WheelSpinApp
//
//  Created by Dang Khoa Dang Le on 26/01/2025.
//

import AVFoundation
import Combine
import Foundation
import SwiftUI

class RouletteViewModel: ObservableObject {
    @Published var segmentCount = 1
    @Published var rotation: Double = 0
    @Published var isSpinning = false
    @Published var winningName: String = ""
    @Published var showAlert = false
    @Published var usedColors: [Color] = [.blue]
    @Published var colors: [Color] = [.gray.opacity(0.3)]
    @Published var names: [String] = [""]
    @Published var winningColor: [String] = []
    @Published var newColorName: String = ""
    @Published var isVisibleFireworks = false

    var selectedColor: Color = .blue
    var lastUsedColor: Color = .clear
    let availableColors: [Color] = [
        .red, .blue, .green, .yellow, .purple, .orange,
    ]
    let totalSpinDuration: Double = 3
    var totalDurations: Double = 3500

    private var player: AVAudioPlayer?

    func spinRoulette() {
        guard !isSpinning && !names[0].isEmpty else { return }
        isSpinning = true

        withAnimation(
            Animation.timingCurve(
                0.1, 0.8, 0.3, 1.0, duration: totalSpinDuration)
        ) {
            rotation += totalDurations
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + totalSpinDuration) {
            [weak self] in
            guard let this = self else { return }
            this.isSpinning = false
            let incompleteRotation = Int(this.rotation) % 360
            let restOfRotation: Double =
                Double(incompleteRotation) / (360 / Double(this.segmentCount))
            let restOfRotationInteger: Int = Int(restOfRotation)
            let winningIndex =
                Double(restOfRotationInteger) == restOfRotation
                ? restOfRotationInteger : restOfRotationInteger + 1
            this.winningColor = this.names.reversed()
            print("winningColor", this.winningColor)
            this.winningName = this.winningColor[winningIndex - 1]
            this.showAlert = true
            this.isVisibleFireworks = true
            this.playSound()
        }

    }
    
    func addNewItems(items: [String]) {
        guard !items.isEmpty else { return }
        names.removeAll(where: { $0 == "" })
        colors.removeAll(where: { $0 == .gray.opacity(0.3) })
        for item in items {
            addNewColorAndName(name: item)
        }
        segmentCount = names.count
    }

    func addNewItems(items: [String]) {
        guard !items.isEmpty else { return }
        names.removeAll(where: { $0 == "" })
        colors.removeAll(where: { $0 == .gray.opacity(0.3) })
        for item in items {
            addNewColorAndName(name: item)
        }
        segmentCount = names.count
    }

    func addNewItems(items: [String]) {
        guard !items.isEmpty else { return }
        names.removeAll(where: { $0 == "" })
        colors.removeAll(where: { $0 == .gray.opacity(0.3) })
        for item in items {
            addNewColorAndName(name: item)
        }
        segmentCount = names.count
    }

    func addNewItem() {
        guard !newColorName.isEmpty else { return }
        addNewColorAndName(name: newColorName)
        names.removeAll(where: { $0 == "" })
        colors.removeAll(where: { $0 == .gray.opacity(0.3) })
        segmentCount = names.count
        newColorName = ""
    }

    func deleteItem(at offset: IndexSet) {
        names.remove(atOffsets: offset)
        segmentCount -= 1
        if names.isEmpty {
            names = [""]
            segmentCount = 1
            colors = [.gray.opacity(0.3)]
        }
    }

    func deleteItemWinner() {
        let index = names.firstIndex(of: winningName)
        if index != nil {
            names.remove(at: index!)
            segmentCount -= 1
            if names.isEmpty {
                names = [""]
                segmentCount = 1
                colors = [.gray.opacity(0.3)]
            }
        }
    }

    func addNewColorAndName(name: String) {
        if usedColors.count < availableColors.count {
            let unusedColors = availableColors.filter {
                !usedColors.contains($0)
            }
            if let randomColor = unusedColors.randomElement() {
                print(randomColor)
                colors.append(randomColor)
                usedColors.append(randomColor)
                lastUsedColor = randomColor
                if availableColors.firstIndex(of: randomColor) != nil {
                    names.append(name)
                }
            }
        } else {
            if let randomColor = availableColors.filter({
                $0 != lastUsedColor && $0 != colors[0]
            }).randomElement() {
                colors.append(randomColor)
                lastUsedColor = randomColor
                if availableColors.firstIndex(of: randomColor) != nil {
                    names.append(name)
                }
            }
        }
    }

    func playSound() {
        guard
            let soundURL = Bundle.main.url(
                forResource: "clapping", withExtension: "mp3")
        else {
            return
        }
        do {
            player = try AVAudioPlayer(contentsOf: soundURL)

        } catch {
            print("Failed to load the sound: \(error)")
        }
        player?.play()
    }
}

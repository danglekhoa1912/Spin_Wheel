//
//  WheelView.swift
//  WheelSpinApp
//
//  Created by Dang Khoa Dang Le on 26/01/2025.
//

import SwiftUI
import Vortex

struct WheelView: View {
    @State var radius: CGFloat = 0.0
    @StateObject var vm = RouletteViewModel()

    var body: some View {
        VStack {
            VStack(spacing: 10) {
                Text("What to watch today?")
                    .font(.title)
                    .fontWeight(.bold)
                Text("Spin the rulette by tapping")
                    .font(.caption)
                    .fontWeight(.light)
            }
            .padding(.bottom, 20)
            
            GeometryReader { geo in
                ZStack {
                    ForEach(0..<vm.segmentCount, id: \.self) { index in
                        ZStack {
                            Segment(
                                startAngle: self.angleForSegment(index),
                                endAngle: self.angleForSegment(index + 1)
                            )
                            .foregroundStyle(vm.colors[index % vm.names.count])
                            .onAppear {
                                let midX = geo.frame(in: .local).midX + 40
                                let midY = geo.frame(in: .local).midY + 40
                                radius = min(midX, midY)
                            }
                            Text(vm.names[index])
                                .foregroundStyle(.white)
                                .font(.headline)
                                .rotationEffect(
                                    angleForSegment(index + 1)
                                        - Angle(degrees: 10)
                                )
                                .offset(
                                    CGSize(
                                        width: {
                                            () -> Double in
                                            let mean: Angle =
                                                (angleForSegment(index)
                                                    + angleForSegment(index + 1))
                                                / 2
                                            return radius * 0.5
                                                * cos(mean.radians)
                                        }(),
                                        height: {
                                            () -> Double in
                                            let mean: Angle =
                                                (angleForSegment(index)
                                                    + angleForSegment(index + 1))
                                                / 2
                                            return radius * 0.5
                                                * sin(mean.radians)
                                        }()
                                    )
                                )
                        }
                        .frame(width: 300, height: 300)
                        .rotationEffect(.degrees(vm.rotation))
                    }
                    Circle()
                        .foregroundStyle(.white)
                        .frame(width: 50, height: 50)

                    Arrow()
                        .foregroundStyle(.gray)
                        .frame(width: 30, height: 30)
                        .rotationEffect(.degrees(180))
                        .offset(x: 150)
                        .shadow(color: .gray, radius: 4, x: 2, y: 2)
                }
                .onTapGesture {
                    print("Ce")
                    vm.spinRoulette()
                }
            }
            .frame(width: 300)

            VStack(spacing: 10) {
                HStack {
                    TextField("Enter Name", text: $vm.newColorName)
                        .padding(.leading)
                        .frame(height: 55)
                        .background(.thinMaterial, in: .rect(cornerRadius: 12))

                    Button {
                        vm.addNewItem()
                    } label: {
                        Text("Add")
                            .bold()
                            .frame(width: 80, height: 55)
                            .background(
                                .thinMaterial, in: .rect(cornerRadius: 12))

                    }
                    .tint(.primary)
                }

                Spacer()

                if vm.names.filter({ $0 != "" }).isEmpty == false {
                    List {
                        ForEach(vm.names, id: \.self) {
                            name in
                            Text(name)
                        }
                        .onDelete(perform: vm.deleteItem)
                    }
                    .listStyle(.grouped)
                    .scrollContentBackground(.hidden)
                }
            }
        }
        .padding(.horizontal, 10)
        .overlay {
            if vm.showAlert {
                Dialog(
                    isPresented: $vm.showAlert, title: "We have Winner!",
                    message: "The winner is \(vm.winningName)",
                    primaryButtonTitle: "Cancel", primaryButtunAction: {},
                    secondaryButtonTitle: "Remove",
                    secondaryButtunAction: vm.deleteItemWinner)
            }
            if vm.isVisibleFireworks {
                VortexView(.fireworks) {
                    Circle()
                        .fill(.white)
                        .frame(width: 32)
                        .tag("circle")
                }
                .allowsHitTesting(false)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 6) {
                        withAnimation(.easeOut) {
                            vm.isVisibleFireworks = false
                        }
                    }
                }
            }
        }

    }

    func angleForSegment(_ index: Int) -> Angle {
        Angle(degrees: Double(index) / Double(vm.names.count) * 360)
    }

    func textAngleForSegment(_ index: Int) -> Angle {
        let segmentAngle = 360.0 / Double(vm.names.count)
        return Angle(degrees: -Double(index) * segmentAngle - segmentAngle / 2)
    }
}

#Preview {
    WheelView()
}

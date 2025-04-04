//
//  WheelView.swift
//  WheelSpinApp
//
//  Created by Dang Khoa Dang Le on 26/01/2025.
//

import CoreImage
import CoreImage.CIFilterBuiltins
import SwiftUI
import Vortex

struct WheelView: View {
    @State var radius: CGFloat = 0.0
    @State private var addNewItem: Bool = false
    @State var showQRCode = false
    @State var itemEdit: SpinWheel? = nil
    @StateObject var vm = RouletteViewModel()
    @StateObject var homeViewModel = HomeViewModel()
    @Environment(\.dismiss) private var dismiss
    @State var spinWheel: SpinWheel? = nil
    @State var shareCode: String? = nil
    @ObservedObject private var spinWheelsTable = SpinWheelsTable.shared
    let notification = NotificationManager.shared

    let spinWheelId: String?
    let context = CIContext()
    let filter = CIFilter.qrCodeGenerator()

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            VStack {
                HStack {
                    Button {
                        if vm.names.count == spinWheel?.labels.count {
                            dismiss()
                        } else {
                            vm.isLabelsChange = true
                        }
                    } label: {
                        CircleButton(iconName: "chevron.left")
                    }
                    Spacer()
                    Text(spinWheel?.title ?? "Spin")
                        .font(.title2)
                        .bold()
                    Spacer()

                    Menu {

                        Button(action: {
                            Task {
                                if let documentID =
                                    await spinWheelsTable
                                    .saveToFirestore(
                                        spinWheel: spinWheel!)
                                {
                                    print(
                                        "✅ Đã lưu lên Firestore với ID: \(documentID)"
                                    )
                                    shareCode = documentID
                                    showQRCode = true
                                } else {
                                    print(
                                        "❌ Không thể lưu lên Firestore"
                                    )
                                    return
                                }
                            }
                        }) {
                            SwiftUI.Label(
                                "QR",
                                systemImage:
                                    "qrcode"
                            )
                        }

                        Button(action: {
                            itemEdit = spinWheel
                        }) {
                            SwiftUI.Label(
                                "Edit",
                                systemImage:
                                    "pencil"
                            )
                        }

                        Button(action: {
                            Task {
                                if let documentID =
                                    await spinWheelsTable
                                    .saveToFirestore(
                                        spinWheel: spinWheel!)
                                {
                                    print(
                                        "✅ Đã lưu lên Firestore với ID: \(documentID)"
                                    )
                                    homeViewModel.shareWheel(
                                        spinWheel: spinWheel!,
                                        documentId:
                                            documentID)
                                } else {
                                    print(
                                        "❌ Không thể lưu lên Firestore"
                                    )
                                    return
                                }
                            }
                        }) {
                            SwiftUI.Label(
                                "Share",
                                systemImage:
                                    "arrowshape.turn.up.right.fill"
                            )
                        }

                        Button(
                            role: .destructive,
                            action: {
                                Task {
                                    if await spinWheelsTable
                                        .deleteSpinWheel(
                                            id: spinWheel!.id)
                                    {
                                        dismiss()
                                        notification
                                            .showNotification(
                                                title:
                                                    "Deleted wheel successfully",
                                                isError:
                                                    false)
                                    } else {
                                        notification
                                            .showNotification(
                                                title:
                                                    "Deleting wheel failed",
                                                isError:
                                                    true)
                                    }

                                }
                            }
                        ) {
                            SwiftUI.Label(
                                "Delete",
                                systemImage: "trash")
                        }

                    } label: {
                        Image(
                            systemName:
                                "ellipsis"
                        )
                        .resizable()
                        .scaledToFit()
                        .frame(width: 20, height: 20)
                        .tint(.black)
                        .rotationEffect(.degrees(90))
                        .padding(20)
                    }
                }

                //            VStack(spacing: 10) {
                //                Text("What to watch today?")
                //                    .font(.title)
                //                    .fontWeight(.bold)
                //                Text("Spin the rulette by tapping")
                //                    .font(.caption)
                //                    .fontWeight(.light)
                //            }
                //            .padding(.bottom, 20)

                GeometryReader { geo in
                    ZStack {
                        ForEach(0..<vm.segmentCount, id: \.self) { index in
                            ZStack {
                                Segment(
                                    startAngle: self.angleForSegment(index),
                                    endAngle: self.angleForSegment(index + 1)
                                )
                                .foregroundStyle(
                                    vm.colors[index % vm.names.count]
                                )
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
                                                        + angleForSegment(
                                                            index + 1))
                                                    / 2
                                                return radius * 0.5
                                                    * cos(mean.radians)
                                            }(),
                                            height: {
                                                () -> Double in
                                                let mean: Angle =
                                                    (angleForSegment(index)
                                                        + angleForSegment(
                                                            index + 1))
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
                        vm.spinRoulette()
                    }
                }
                .frame(width: 300)

                VStack(spacing: 10) {
                    //                HStack {
                    //                    TextField("Enter Name", text: $vm.newColorName)
                    //                        .padding(.leading)
                    //                        .frame(height: 55)
                    //                        .background(.thinMaterial, in: .rect(cornerRadius: 12))
                    //
                    //                    Button {
                    //                        vm.addNewItem()
                    //                    } label: {
                    //                        Text("Add")
                    //                            .bold()
                    //                            .frame(width: 80, height: 55)
                    //                            .background(
                    //                                .thinMaterial, in: .rect(cornerRadius: 12))
                    //
                    //                    }
                    //                    .tint(.primary)
                    //                }

                    Spacer()

                    VStack {
                        if vm.names.filter({ $0 != "" }).isEmpty == false {
                            List {
                                ForEach(vm.names, id: \.self) {
                                    name in
                                    Text(name)
                                        .listRowBackground(
                                            Color.gray.opacity(0.2))
                                }
                                .onDelete(perform: vm.deleteItem)
                            }
                            .listStyle(.plain)
                            .modifier(ListBackgroundModifier())
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(.gray.opacity(0.2))
                    .cornerRadius(20)

                }
            }
            .padding(.horizontal, 10)

            Button {
                addNewItem.toggle()
            } label: {
                Image(systemName: "plus")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(width: 55, height: 55)
                    .background(
                        Color.primary,
                        in: .circle
                    )
                    .shadow(
                        color: .black.opacity(0.25), radius: 5, x: 10, y: 10)
            }
            .padding(15)
        }
        .navigationBarHidden(true)
        .background(
            LinearGradient(
                colors: [Color(hex: "#8EC5FC"), Color(hex: "#E0C3FC")],
                startPoint: .bottomLeading, endPoint: .topTrailing)
        )
        .overlay {
            Dialog(
                isPresented: $vm.isLabelsChange, title: "Confirm Exit!",
                message: {
                    AnyView(
                        Text(
                            "Do you want to save the changes to the item list?")
                    )
                },
                primaryButtonTitle: "No",
                primaryButtunAction: {
                    dismiss()
                },
                secondaryButtonTitle: "Save",
                secondaryButtunAction: {
                    if vm.updateLabelsById(spinWheel: spinWheel!) {
                        dismiss()
                    }
                })
        }
        .overlay {
            if vm.showAlert {
                Dialog(
                    isPresented: $vm.showAlert, title: "We have Winner!",
                    message: {
                        AnyView(
                            Text("The winner is \(vm.winningName)")
                        )
                    },
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
            if showQRCode {
                Dialog(
                    isPresented: $showQRCode, title: "QR Code",
                    message: {
                        AnyView(
                            Image(
                                uiImage: generateQRCode(from: "\(shareCode!)")
                            )
                            .resizable()
                            .scaledToFit()
                            .frame(width: 200, height: 200)
                        )
                    }, primaryButtonTitle: "Close", primaryButtunAction: {})
            }
        }
        .sheet(
            isPresented: $addNewItem
        ) {
            let newItemView = NewItemView(
                item: $vm.newColorName,
                onConfirm: { vm.addNewItem() }
            )
            if #available(iOS 16.4, *) {
                newItemView
                    .presentationDetents([.height(200)])
                    .interactiveDismissDisabled()
                    .presentationCornerRadius(30)
                    .presentationBackground(.white)
            } else {
                newItemView
            }
        }
        .sheet(
            item: $itemEdit,
            onDismiss: {
                Task {
                    spinWheel = await spinWheelsTable.getSpinWheelDetail(
                        id: spinWheel!.id)
                    if spinWheel != nil {
                        vm.removeAndAddItems(items: spinWheel!.labels)
                    }
                }
            },
            content: { item in
                if #available(iOS 17.0, *) {
                    NewSpinWheelView(spinWheelItem: item)
                        .interactiveDismissDisabled()
                        .presentationCornerRadius(30)
                        .presentationBackground(.white)
                } else {
                    NewSpinWheelView(spinWheelItem: item)
                        .interactiveDismissDisabled()
                        .background(Color.white)
                        .cornerRadius(30)
                }
            }
        )
        .sheet(isPresented: $homeViewModel.showingShareSheet) {
            ActivityViewController(items: homeViewModel.shareItems)
        }
        .onAppear {
            Task {
                if spinWheelId != nil {
                    spinWheel = await SpinWheelsTable.shared.getSpinWheelDetail(
                        id: spinWheelId!)
                    if spinWheel != nil {
                        vm.addNewItems(items: spinWheel!.labels)
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

    func generateQRCode(from string: String) -> UIImage {
        filter.message = Data(string.utf8)

        if let outputImage = filter.outputImage {
            if let cgimg = context.createCGImage(
                outputImage, from: outputImage.extent)
            {
                return UIImage(cgImage: cgimg)
            }
        }
        return UIImage(systemName: "xmark.circle") ?? UIImage()
    }
    
    struct ActivityViewController: UIViewControllerRepresentable {
        let items: [Any]

        func makeUIViewController(context: Context) -> UIActivityViewController
        {
            let controller = UIActivityViewController(
                activityItems: items, applicationActivities: nil)
            return controller
        }

        func updateUIViewController(
            _ uiViewController: UIActivityViewController, context: Context
        ) {}
    }
}

#Preview {
    WheelView(spinWheelId: nil)
}

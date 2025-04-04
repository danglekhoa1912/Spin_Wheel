//
//  HomeView.swift
//  WheelSpinApp
//
//  Created by Dang Khoa Dang Le on 27/01/2025.
//

import SwiftUI

struct HomeView: View {
    @State var showCreateSpinWheel = false
    @State var showScanner = false
    @StateObject var vm = HomeViewModel()
    @ObservedObject private var spinWheelsTable = SpinWheelsTable.shared
    let notification = NotificationManager.shared

    var body: some View {
        VStack(spacing: 30) {
            RoundedRectangle(cornerRadius: 20)
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color.primary, Color.primary.opacity(0.6),
                        ]), startPoint: .topLeading,
                        endPoint: .bottomTrailing)
                )
                .frame(height: 180)
                .overlay {
                    HStack {
                        VStack(alignment: .leading) {
                            Text("Win everyday")
                                .font(.title2)
                                .bold()
                                .foregroundColor(.white)
                            NavigationLink {
                                WheelView(spinWheelId: nil)
                            } label: {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 20)
                                        .foregroundColor(Color.secondary)
                                        .frame(
                                            minWidth: 0, maxWidth: .infinity
                                        )

                                    Text("Spin now")
                                        .font(
                                            .system(size: 16, weight: .bold)
                                        )
                                        .foregroundColor(.white)
                                        .padding()
                                }
                                .fixedSize()
                            }
                        }
                        Spacer()
                        Image(name: .logoApp)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 100, height: 100)
                    }
                    .padding()
                }

            VStack {
                HStack {
                    Text("Spin saved")
                        .font(.title2)
                        .fontWeight(.semibold)
                    Spacer()
                    Button {

                    } label: {
                        Text("Show all")
                    }
                }

                List {
                    ForEach(spinWheelsTable.spinWheels) { item in
                        ZStack {
                            NavigationLink(
                                destination: WheelView(spinWheelId: item.id)
                            ) {
                                EmptyView()
                            }.opacity(0.0)
                            RoundedRectangle(cornerRadius: 20)
                                .fill(.white)
                                .frame(height: 100)
                                .shadow(radius: 2)
                                .listRowSeparator(.hidden)
                                .overlay {
                                    HStack {
                                        VStack(
                                            alignment: .leading, spacing: 10
                                        ) {
                                            Text(item.title)
                                                .foregroundColor(.black)
                                                .font(.title3)
                                                .fontWeight(.semibold)
                                            Text(
                                                "Spins: \(item.labels.count)"
                                            )
                                            .foregroundColor(.black)
                                            .font(.caption)
                                            .fontWeight(.thin)
                                        }

                                        Spacer()

                                        Menu {
                                            Button(action: {
                                                Task {
                                                    if let documentID =
                                                        await spinWheelsTable
                                                        .saveToFirestore(
                                                            spinWheel: item)
                                                    {
                                                        print(
                                                            "✅ Đã lưu lên Firestore với ID: \(documentID)"
                                                        )
                                                        vm.shareWheel(
                                                            spinWheel: item,
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
                                                                id: item.id)
                                                        {
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
                                                    "ellipsis.circle"
                                            )
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 20, height: 20)
                                            .tint(.black)
                                        }

                                    }
                                    .hSpacing(.leading)
                                    .padding()
                                }
                        }
                        .listRowSeparator(.hidden)
                        .transition(
                            .asymmetric(
                                insertion: .move(edge: .trailing).combined(
                                    with: .opacity),
                                removal: .move(edge: .leading).combined(
                                    with: .opacity)
                            ))

                    }
                    .listRowInsets(EdgeInsets())
                    .listRowBackground(Color.clear)
                }
                .listRowSpacing(10)
                .listStyle(.plain)
                .modifier(ListBackgroundModifier())
                .animation(
                    .easeInOut(duration: 0.5), value: spinWheelsTable.spinWheels
                )

            }
            Spacer()
        }
        //            Button {
        //                showCreateSpinWheel = true
        //            } label: {
        //                Image(systemName: "plus")
        //                    .font(.system(size: 17, weight: .semibold))
        //                    .foregroundStyle(.white)
        //                    .frame(width: 55, height: 55)
        //                    .background(
        //                        Color.primary,
        //                        in: .circle
        //                    )
        //                            .shadow(
        //                                color: .black.opacity(0.25), radius: 5, x: 10, y: 10)
        //            }
        .padding()
        .background(
            LinearGradient(
                colors: [Color(hex: "#8EC5FC"), Color(hex: "#E0C3FC")],
                startPoint: .bottomLeading, endPoint: .topTrailing)
        )
        .navigationBarHidden(true)
        .sheet(
            isPresented: $showCreateSpinWheel,
            content: {
                if #available(iOS 17.0, *) {
                    NewSpinWheelView()
                        .interactiveDismissDisabled()
                        .presentationCornerRadius(30)
                        .presentationBackground(.white)
                } else {
                    NewSpinWheelView()
                        .interactiveDismissDisabled()
                        .background(Color.white)
                        .cornerRadius(30)
                }
            }
        )
        .sheet(isPresented: $vm.showingShareSheet) {
            ActivityViewController(items: vm.shareItems)
        }
        .fullScreenCover(isPresented: $showScanner) {
            ScannerView()
        }
        .overlay(alignment: .bottomTrailing) {
            FloatingButton {
                FloatingAction(symbol: "qrcode") {
                    showScanner = true
                }

                FloatingAction(symbol: "folder.fill.badge.plus") {
                    showCreateSpinWheel = true
                }

            } label: {
                isExpanded in
                Image(systemName: "plus")
                    .font(.title3)
                    .foregroundStyle(.white)
                    .rotationEffect(.init(degrees: isExpanded ? 45 : 0))
                    .scaleEffect(1.02)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.primary, in: .circle)
                    .scaleEffect(isExpanded ? 0.9 : 1)
                    .shadow(
                        color: .black.opacity(0.25), radius: 5, x: 10, y: 10)
            }
            .padding()
        }
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
    HomeView()
}

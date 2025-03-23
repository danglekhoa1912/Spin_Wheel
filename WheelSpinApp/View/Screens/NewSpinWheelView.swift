//
//  NewSpinWheel.swift
//  WheelSpinApp
//
//  Created by Dang Khoa Dang Le on 28/01/2025.
//

import SwiftUI

struct NewSpinWheelView: View {

    @Environment(\.dismiss) private var dismiss
    @StateObject var vm = SpinWheelModel()

    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            ZStack {
                Text("Add new spin wheel")
                    .foregroundColor(.black)
                    .font(.title3)
                    .fontWeight(.medium)
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title)
                        .tint(.red)
                }
                .hSpacing(.trailing)
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("Title")
                    .font(.caption)
                    .foregroundStyle(.gray)

                TextField("Enter your title", text: $vm.title)
                    .foregroundColor(.black)
                    .padding(.leading)
                    .frame(height: 55)
                    .background(.thinMaterial, in: .rect(cornerRadius: 12))
                    .environment(\.colorScheme, .light)
            }
            .padding(.top, 5)

            VStack(alignment: .leading, spacing: 8) {
                Text("Labels")
                    .font(.caption)
                    .foregroundStyle(.gray)

                HStack {
                    TextField("Enter label", text: $vm.newLabel)
                        .foregroundColor(.black)
                        .padding(.leading)
                        .frame(height: 55)
                        .background(.thinMaterial, in: .rect(cornerRadius: 12))
                        .environment(\.colorScheme, .light)

                    Button {
                        vm.addNewLabel()
                    } label: {
                        Text("Add")
                            .bold()
                            .frame(width: 80, height: 55)
                            .background(
                                .thinMaterial, in: .rect(cornerRadius: 12)
                            )
                            .environment(\.colorScheme, .light)

                    }
                    .disabled(vm.newLabel.isEmpty)
                    .tint(.primary)
                }

                VStack {
                    List {
                        ForEach(vm.labels) {
                            label in
                            Text(label.value)
                                .foregroundColor(.black)
                                .listRowBackground(
                                    Color.gray.opacity(0.2))
                        }
                        .onDelete(perform: vm.deleteLabel)
                    }
                    .listStyle(.plain)
                    .modifier(ListBackgroundModifier())
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(.gray.opacity(0.2))
                .cornerRadius(20)

            }
            .padding(.top, 10)

            Spacer(minLength: 0)

            Button {
                Task {
                    await vm.createSpinWheel()
                }
                dismiss()
            } label: {
                Text("Create Spin")
                    .font(.system(size: 20, weight: .semibold))
                    .font(.title3)
                    .foregroundStyle(.black)
                    .hSpacing(.center)
                    .padding(.vertical, 12)
                    .background(Color.primary, in: .rect(cornerRadius: 10))
            }
            .disabled(!vm.isValid)
            .opacity(!vm.isValid ? 0.5 : 1)
        }
        .padding(15)
    }
}

#Preview {
    NewSpinWheelView()
}

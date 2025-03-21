//
//  NewItemView.swift
//  WheelSpinApp
//
//  Created by Dang Khoa Dang Le on 27/01/2025.
//

import SwiftUI

struct NewItemView: View {
    @Environment(\.dismiss) private var dismiss
    
    @Binding var item: String;
    
    let onConfirm: () -> ()

    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            ZStack {
                Text("Add new item")
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

                TextField("Enter Name!", text: $item)
                    .foregroundColor(.black)
                    .accentColor(.gray)
                    .padding(.vertical, 12)
                    .padding(.horizontal, 15)
                    .background(
                        .white.shadow(
                            .drop(color: .black.opacity(0.25), radius: 2)),
                        in: .rect(cornerRadius: 10))
            }
            .padding(.top, 5)

            Spacer(minLength: 0)

            Button {
                onConfirm()
                dismiss()
            } label: {
                Text("Add")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .textScale(.secondary)
                    .foregroundStyle(.black)
                    .hSpacing(.center)
                    .padding(.vertical, 12)
                    .background(Color.primary, in: .rect(cornerRadius: 10))
            }
            .disabled(item.isEmpty)
            .opacity(item.isEmpty ? 0.5 : 1)
        }
        .padding(15)
    }
}

#Preview {
    NewItemView(item: .constant(""), onConfirm: {})
        .vSpacing(.bottom)
}

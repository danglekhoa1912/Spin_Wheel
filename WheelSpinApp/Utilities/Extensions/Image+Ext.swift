//
//  Image+Ext.swift
//  WheelSpinApp
//
//  Created by Dang Khoa Dang Le on 27/01/2025.
//

import SwiftUI

enum ImageName: String {
    case logo
}

extension Image {
    init(name: ImageName) {
        self.init(name.rawValue)
    }
}

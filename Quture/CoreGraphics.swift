//
//  CoreGraphics.swift
//  Quture
//
//  Created by Peter Zhang on 2024/3/6.
//

import Foundation
import CoreGraphics
import SwiftUI

struct LayoutConfig {
    static let totalHorizontalPadding: CGFloat = 32
    static let numberOfColumns: CGFloat = 2
    static let spacing: CGFloat = 10 // Define your spacing value here

    static var rectangleWidth: CGFloat {
        return (UIScreen.main.bounds.width - totalHorizontalPadding) / numberOfColumns
    }
    
    static var rectangleHeight: CGFloat {
        return rectangleWidth * (4 / 3)
    }
}

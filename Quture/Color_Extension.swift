//
//  Color_Extension.swift
//  Quture
//
//  Created by Peter Zhang on 2024/3/3.
//

import Foundation
import SwiftUI

extension Color {
    static let coralGreen = Color(red: 62 / 255, green: 178 / 255, blue: 174 / 255)
    
    static func contrastColor(for colorScheme: ColorScheme) -> Color {
            colorScheme == .dark ? .white : .black
        }
    
    static func sameColor(forScheme scheme: ColorScheme) -> Color {
            scheme == .dark ? .black : .white
        }
}

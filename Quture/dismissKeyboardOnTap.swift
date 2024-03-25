//
//  dismissKeyboardOnTap.swift
//  Quture
//
//  Created by Peter Zhang on 2024/3/9.
//

import Foundation
#if canImport(UIKit)
import SwiftUI

extension View {
    func dismissKeyboardOnTap() -> some View {
        self.onTapGesture {
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        }
    }
}
#endif

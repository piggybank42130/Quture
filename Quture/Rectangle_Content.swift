//
//  Rectangle_Content.swift
//  Quture
//
//  Created by Peter Zhang on 2024/3/3.
//

import Foundation
import SwiftUI

//MARK: Contents within the rectangle content regions
struct RectangleContent {
    var userId: Int
    var imageId: Int
    var image: UIImage?
    var caption: String
 //   var tags: [String] // Add this
    var tags: [Tag] = []
}

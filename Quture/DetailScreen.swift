//
//  DetailScreen.swift
//  Quture
//
//  Created by Peter Zhang on 2024/3/3.
//

import SwiftUI
import UIKit

//MARK: DetailScreen (After selecting image)
struct DetailScreen: View {
    var image: UIImage
    @State var caption: String
    var onConfirm: ((UIImage, String) -> Void)?
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        VStack {
            Image(uiImage: image)
                .resizable()
                .scaledToFit()
            
            TextField("Enter a caption...", text: $caption)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            
            Button("Confirm") {
                onConfirm?(image, caption)
                presentationMode.wrappedValue.dismiss()
            }
            .padding()
        }
    }
}

struct DetailScreen_Previews: PreviewProvider {
    static var previews: some View {
        // Use a system image as a placeholder
        let placeholderImage = UIImage(systemName: "photo")!
        
        DetailScreen(image: placeholderImage, caption: "Sample Caption")
    }
}

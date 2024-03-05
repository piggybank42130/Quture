//
//  ImagePicker.swift
//  Quture
//
//  Created by Peter Zhang on 2024/3/3.
//

import SwiftUI

struct ImagePicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    @Environment(\.presentationMode) var presentationMode

    func makeUIViewController(context: Context) -> some UIViewController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.image = image
            }
            
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
}

// Preview provider for ImagePicker
struct ImagePicker_Previews: PreviewProvider {
    // Temporary view to hold a state variable for the image
    struct PreviewWrapper: View {
        // State variable to hold the selected image
        @State private var image: UIImage?

        var body: some View {
            // Pass the state variable as a binding to ImagePicker
            ImagePicker(image: $image)
        }
    }

    static var previews: some View {
        // Render the wrapper view in the preview
        PreviewWrapper()
    }
}

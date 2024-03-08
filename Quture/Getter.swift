//
//  Getter.swift
//  Quture
//
//  Created by Rohan Tan Bhowmik on 3/7/24.
//

import SwiftUI
import Swift
import Foundation

class Getter: ObservableObject {
    func postImage(image: UIImage, caption: String) {
        guard let imageData = image.jpegData(compressionQuality: 0.5) else { return }
        let base64ImageString = imageData.base64EncodedString()
        
        // Assuming 'sendMethod' properly sets up a POST request including setting
        // the 'Content-Type' header to 'application/json'.
        let parameters: [String: Any] = ["method_name": "post_image", "params": ["image_data": base64ImageString, "user_id": 31353, "caption": caption]]
        
        ServerCommunicator().sendMethod(parameters: parameters) { result in
            switch result {
            case .success(let responseData):
                // Assuming responseData is of type Data and can be converted to a String or JSON
                print("Image posted successfully: \(String(describing: responseData))")
                // Further processing of responseData if necessary
                
            case .failure(let error):
                print("Failed to post image: \(error.localizedDescription)")
                // Consider user-friendly error handling here
            }
        }
    }
    
    //###GETTERS###//
    
    func retrieveImage(imageId: Int, completion: @escaping (UIImage?, Error?) -> Void) {
        let parameters: [String: Any] = [
            "method_name": "retrieve_image", // Ensure this matches a valid method in your Flask app
            "params": ["image_id": imageId]
        ]
        
        ServerCommunicator().sendMethod(parameters: parameters) { result in
            switch result {
            case .success(let data):
                do {
                    if let jsonResponse = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any], let result = jsonResponse["result"] as? [String: Any],
                       let imageDataList = result["image_data"] as? [String: Any], let imageDataString = imageDataList["image_data"] as? String { // Assuming 'image_data' is the correct key
                        // Convert Base64 string to UIImage
                        if let imageData = Data(base64Encoded: imageDataString),
                           let image = UIImage(data: imageData) {
                            completion(image, nil) // Successfully converted and returning the image
                        } else {
                            // Failed to convert Base64 string to UIImage
                            completion(nil, NSError(domain: "ImageConversionError", code: 200, userInfo: [NSLocalizedDescriptionKey: "Failed to convert image data."]))
                        }
                    } else {
                        // The JSON is not in the expected format
                        print("Error: Unexpected JSON format.")
                        completion(nil, NSError(domain: "CustomError", code: 100, userInfo: [NSLocalizedDescriptionKey: "Unexpected JSON format."]))
                    }
                } catch {
                    // An error occurred during JSON deserialization
                    print("Failed to load: \(error.localizedDescription)")
                    completion(nil, error)
                }
            case .failure(let error):
                print("Error: \(error)")
                completion(nil, error)
            }
        }
    }
    
    func getImagesForUser(userId: Int, completion: @escaping ([UIImage]?, Error?) -> Void) {
        getUserImages(userId: userId) { (imageIds, error) in
            if let error = error {
                completion(nil, error)
                return
            }
            
            guard let imageIds = imageIds else {
                completion(nil, NSError(domain: "ImageFetcherError", code: 300, userInfo: [NSLocalizedDescriptionKey: "No image IDs found."]))
                return
            }
            
            var images = [UIImage]()
            let group = DispatchGroup()
            
            for imageId in imageIds {
                group.enter()
                self.retrieveImage(imageId: imageId) { image, error in
                    defer { group.leave() }
                    print(image)
                    if let image = image {
                        images.append(image)
                    } else {
                        print("Error or no image for ID \(imageId). Error: \(error?.localizedDescription ?? "Unknown error")")
                        // Adjusted error handling: No longer using `continue`
                    }
                }
            }
            
            group.notify(queue: .main) {
                completion(images, nil)
            }
        }
    }
    
    func getUserImages(userId: Int, completion: @escaping ([Int]?, Error?) -> Void) {
        let parameters: [String: Any] = [
            "method_name": "get_user_images", // Ensure this matches a valid method in your Flask app
            "params": ["user_id": userId]
        ]
        
        ServerCommunicator().sendMethod(parameters: parameters) { result in
            switch result {
            case .success(let data):
                do {
                    if let jsonResponse = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                       let result = jsonResponse["result"] as? [String: Any],
                       let imageIds = result["image_ids"] as? [Int] {
                        
                        print("Successfully retrieved image IDs: \(imageIds)")
                        completion(imageIds, nil)
                    } else {
                        // The JSON is not in the expected format
                        print("Error: Unexpected JSON format.")
                        completion(nil, NSError(domain: "CustomError", code: 100, userInfo: [NSLocalizedDescriptionKey: "Unexpected JSON format."]))
                    }
                } catch {
                    // An error occurred during JSON deserialization
                    print("Failed to load: \(error.localizedDescription)")
                    completion(nil, error)
                }
            case .failure(let error):
                print("Error: \(error)")
                completion(nil, error)
            }
        }
    }
}

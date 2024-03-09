//
//  Getter.swift
//  Quture
//
//  Created by Rohan Tan Bhowmik on 3/7/24.
//

import SwiftUI
import Swift
import Foundation

class ServerCommands: ObservableObject {
    func postImage(image: UIImage, caption: String, completion: @escaping (Int?, Error?) -> Void) {
        guard let imageData = image.jpegData(compressionQuality: 0.5) else { return }
        let base64ImageString = imageData.base64EncodedString()
        
        // Assuming 'sendMethod' properly sets up a POST request including setting
        // the 'Content-Type' header to 'application/json'.
        let parameters: [String: Any] = ["method_name": "post_image", "params": ["image_data": base64ImageString, "user_id": 31353, "caption": caption]]
        
        ServerCommunicator().sendMethod(parameters: parameters) { result in
            switch result {
            case .success(let data):
                // Assuming responseData is of type Data and can be converted to a String or JSON
                print("Image posted successfully: \(String(describing: data))")
                // Further processing of responseData if necessary
                
                do {
                    if let jsonResponse = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                       let result = jsonResponse["result"] as? [String: Any],
                       let newImageId = result["new_image_id"] as? Int { // Assuming 'caption' is the correct key for the image caption
                        // Convert Base64 string to UIImage
                        print(newImageId)
                        completion(newImageId, nil) // Successfully converted and returning the image with caption

                    } else {
                        // The JSON is not in the expected format
                        completion(nil, NSError(domain: "CustomError", code: 100, userInfo: [NSLocalizedDescriptionKey: "Unexpected JSON format."]))
                    }
                } catch {
                    // An error occurred during JSON deserialization
                    completion(nil, error)
                }
                
            case .failure(let error):
                print("Failed to post image: \(error.localizedDescription)")
                // Consider user-friendly error handling here
            }
        }
    }
    
    func toggleLikeOnImage(userId: Int, imageId: Int) {
        // Assuming 'sendMethod' properly sets up a POST request including setting
        // the 'Content-Type' header to 'application/json'.
        let parameters: [String: Any] = ["method_name": "toggle_like_on_image", "params": ["user_id": userId, "image_id": imageId]]
        
        ServerCommunicator().sendMethod(parameters: parameters) { result in
            switch result {
            case .success(let responseData):
                // Assuming responseData is of type Data and can be converted to a String or JSON
                print("Image liked successfully: \(String(describing: responseData))")
                // Further processing of responseData if necessary
                
            case .failure(let error):
                print("Failed to post image: \(error.localizedDescription)")
                // Consider user-friendly error handling here
            }
        }
    }
    
    //###GETTERS###//
    
    func getLikesOnImage(imageId: Int, completion: @escaping (Int?, Error?) -> Void) {
        // Assuming 'sendMethod' properly sets up a POST request including setting
        // the 'Content-Type' header to 'application/json'.
        let parameters: [String: Any] = ["method_name": "toggle_like_on_image", "params": ["image_id": imageId]]
        
        ServerCommunicator().sendMethod(parameters: parameters) { result in
            switch result {
            case .success(let data):
                // Assuming responseData is of type Data and can be converted to a String or JSON
                print("Image posted successfully: \(String(describing: data))")
                // Further processing of responseData if necessary
                
                do {
                    if let jsonResponse = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                       let result = jsonResponse["result"] as? [String: Any],
                       let like_count = result["like_count"] as? Int { // Assuming 'caption' is the correct key for the image caption
                        // Convert Base64 string to UIImage
                        print(like_count)
                        completion(like_count, nil) // Successfully converted and returning the image with caption

                    } else {
                        // The JSON is not in the expected format
                        completion(nil, NSError(domain: "CustomError", code: 100, userInfo: [NSLocalizedDescriptionKey: "Unexpected JSON format."]))
                    }
                } catch {
                    // An error occurred during JSON deserialization
                    completion(nil, error)
                }
                
            case .failure(let error):
                print("Failed to get like count: \(error.localizedDescription)")
                // Consider user-friendly error handling here
            }
        }
    }
    
    func retrieveImage(imageId: Int, completion: @escaping (UIImage?, String?, Error?) -> Void) {
        let parameters: [String: Any] = [
            "method_name": "retrieve_image",
            "params": ["image_id": imageId]
        ]
        
        ServerCommunicator().sendMethod(parameters: parameters) { result in
            switch result {
            case .success(let data):
                do {
                    if let jsonResponse = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                       let result = jsonResponse["result"] as? [String: Any],
                       let imageDataList = result["image_data"] as? [String: Any],
                       let imageDataString = imageDataList["image_data"] as? String,
                       let imageCaption = imageDataList["caption"] as? String { // Assuming 'caption' is the correct key for the image caption
                        // Convert Base64 string to UIImage
                        if let imageData = Data(base64Encoded: imageDataString),
                           let image = UIImage(data: imageData) {
                            completion(image, imageCaption, nil) // Successfully converted and returning the image with caption
                        } else {
                            // Failed to convert Base64 string to UIImage
                            completion(nil, nil, NSError(domain: "ImageConversionError", code: 200, userInfo: [NSLocalizedDescriptionKey: "Failed to convert image data."]))
                        }
                    } else {
                        // The JSON is not in the expected format
                        completion(nil, nil, NSError(domain: "CustomError", code: 100, userInfo: [NSLocalizedDescriptionKey: "Unexpected JSON format."]))
                    }
                } catch {
                    // An error occurred during JSON deserialization
                    completion(nil, nil, error)
                }
            case .failure(let error):
                completion(nil, nil, error)
            }
        }
    }

    
    func getImagesForUser(userId: Int, completion: @escaping ([UIImage]?, [String]?, Error?) -> Void) {
        getUserImageIds(userId: userId) { (imageIds, error) in
            if let error = error {
                completion(nil, nil, error)
                return
            }
            
            guard let imageIds = imageIds else {
                completion(nil, nil, NSError(domain: "ImageFetcherError", code: 300, userInfo: [NSLocalizedDescriptionKey: "No image IDs found."]))
                return
            }
            
            var images = [UIImage]()
            var captions = [String]()
            let group = DispatchGroup()
            
            for imageId in imageIds {
                group.enter()
                self.retrieveImage(imageId: imageId) { image, caption, error in
                    defer { group.leave() }
                    print(image)
                    if let image = image, let caption = caption {
                        images.append(image)
                        captions.append(caption)
                    } else {
                        print("Error or no image for ID \(imageId). Error: \(error?.localizedDescription ?? "Unknown error")")
                    }
                }
            }
            
            group.notify(queue: .main) {
                completion(images, captions, nil)
            }
        }
    }

    
    func getUserImageIds(userId: Int, completion: @escaping ([Int]?, Error?) -> Void) {
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

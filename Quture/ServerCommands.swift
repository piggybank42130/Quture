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
        let parameters: [String: Any] = ["method_name": "post_image", "params": ["image_data": base64ImageString, "user_id": 3, "caption": caption]]
        
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
    
    func setTagsToImage(imageId: Int, tags: Set<Tag>, completion: @escaping (Bool, Error?) -> Void) {
        // Convert Set of tagIds to an array of dictionaries for JSON serialization, setting interest level to 1.0 for each
        let tagsWithInterestArray = tags.map { tag -> [String: Any] in
            let tagId = tag.tagId // This function needs to return the unique identifier for the tag.
            return ["tag_id": tagId, "interest_level": 1.0]
        }
        
        let parameters: [String: Any] = [
            "method_name": "set_tags_to_image",
            "params": [
                "image_id": imageId,
                "tags_with_interest": tagsWithInterestArray
            ]
        ]
        
        ServerCommunicator().sendMethod(parameters: parameters) { result in
            switch result {
            case .success(let data):
                do {
                    if let jsonResponse = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]{
                        if
                       let result = jsonResponse["result"] as? [String: Any],
                       let success = result["success"] as? String, !success.isEmpty {
                            // Assuming the server returns a "success" flag when tags are successfully associated
                            completion(true, nil)
                        }
                    } else {
                        // Handle cases where the operation was not successful or the expected data was not returned
                        completion(false, NSError(domain: "CustomError", code: 101, userInfo: [NSLocalizedDescriptionKey: "Failed to set tags to image."]))
                    }
                } catch {
                    // Handle JSON deserialization error
                    completion(false, error)
                }
            case .failure(let error):
                // Handle communication error
                completion(false, error)
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
    
    func getTagsFromImage(imageId: Int, completion: @escaping (Result<[Tag], Error>) -> Void) {
        // Define the parameters, including the method name expected by the server and the image ID
        let parameters: [String: Any] = [
            "method_name": "get_image_tags", // Adjust this to match the actual method name expected by the server
            "params": ["image_id": imageId]
        ]
        
        // Use sendMethod to make the request
        ServerCommunicator().sendMethod(parameters: parameters) { result in
            switch result {
                case .success(let data):
                    do {
                        if let jsonResponse = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]{
                            //print(jsonResponse["result"])
                            if let tagsArray = jsonResponse["result"] as? [String: Any]{
                                print(tagsArray)
                                if let tagDicts = tagsArray["tags"] as? [[String: Any]]{
                                    var tags: [Tag] = [] // Prepare an empty array to hold Tag objects

                                    // Iterate over each dictionary in the array
                                    for tagDict in tagDicts {
                                        // Attempt to parse each dictionary into a Tag object
                                        if let tagId = tagDict["tag_id"] as? Int,
                                           let tagName = tagDict["tag_name"] as? String,
                                           let categoryString = tagDict["category"] as? String { // Convert string to enum
                                            let tag = Tag(tagId: tagId, name: tagName, category: .top)
                                            tags.append(tag)
                                            print(tag)
                                            
                                        } else {
                                            // Handle error if the dictionary does not contain the expected types or values
                                            print("Error parsing tag dictionary: \(tagDict)")
                                        }
                                    }
                                    // If successfully parsed, return the array of Tag objects
                                    completion(.success(tags))
                                }
                            } else {
                                // The JSON is not in the expected format
                                completion(.failure(NSError(domain: "CustomError", code: 100, userInfo: [NSLocalizedDescriptionKey: "Unexpected JSON format."])))
                            }
                        }
                    } catch {
                        // An error occurred during JSON deserialization or decoding
                        completion(.failure(error))
                    }
                case .failure(let error):
                    completion(.failure(error))
            }
        }
    }

    
    
    func hasUserLikedImage(userId: Int, imageId: Int, completion: @escaping (Bool?, Error?) -> Void) {
        // Assuming 'sendMethod' properly sets up a POST request including setting
        // the 'Content-Type' header to 'application/json'.
        let parameters: [String: Any] = ["method_name": "has_user_liked_image", "params": ["user_id": userId, "image_id": imageId]]
        
        ServerCommunicator().sendMethod(parameters: parameters) { result in
            switch result {
            case .success(let data):
                // Assuming responseData is of type Data and can be converted to a String or JSON
                do {
                    if let jsonResponse = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                       let result = jsonResponse["result"] as? [String: Any],
                       let hasLiked = result["has_liked"] as? String {
                        completion(hasLiked == "True", nil)
                    } else {
                        // The JSON is not in the expected format
                        completion(nil, NSError(domain: "CustomError", code: 100, userInfo: [NSLocalizedDescriptionKey: "Unexpected JSON format."]))
                    }
                } catch {
                    // An error occurred during JSON deserialization
                    completion(nil, error)
                }
                
            case .failure(let error):
                print("Failed to query like status: \(error.localizedDescription)")
                completion(nil, error) // Pass the error through to the completion handler
            }
        }
    }

    
    func getLikesOnImage(imageId: Int, completion: @escaping (Int?, Error?) -> Void) {
        // Assuming 'sendMethod' properly sets up a POST request including setting
        // the 'Content-Type' header to 'application/json'.
        let parameters: [String: Any] = ["method_name": "get_image_like_count", "params": ["image_id": imageId]]
        
        ServerCommunicator().sendMethod(parameters: parameters) { result in
            switch result {
            case .success(let data):
                // Assuming responseData is of type Data and can be converted to a String or JSON                
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

    
    func getImagesForUser(userId: Int, completion: @escaping ([Int]?, [UIImage]?, [String]?, Error?) -> Void) {
        getUserImageIds(userId: userId) { (imageIds, error) in
            if let error = error {
                completion(nil, nil, nil, error)
                return
            }
            
            guard let imageIds = imageIds else {
                completion(nil, nil, nil, NSError(domain: "ImageFetcherError", code: 300, userInfo: [NSLocalizedDescriptionKey: "No image IDs found."]))
                return
            }
            
            var images = [UIImage]()
            var captions = [String]()
            let group = DispatchGroup()
            
            for imageId in imageIds {
                group.enter()
                self.retrieveImage(imageId: imageId) { image, caption, error in
                    defer { group.leave() }
                    if let image = image, let caption = caption {
                        images.append(image)
                        captions.append(caption)
                    } else {
                        print("Error or no image for ID \(imageId). Error: \(error?.localizedDescription ?? "Unknown error")")
                    }
                }
            }
            
            group.notify(queue: .main) {
                completion(imageIds, images, captions, nil)
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

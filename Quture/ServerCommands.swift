////
////  Getter.swift
////  Quture
////
////  Created by Rohan Tan Bhowmik on 3/7/24.
////


import SwiftUI
import Swift
import Foundation
import UIKit

class ServerCommands: ObservableObject {
    @Published var serverCommunicator = ServerCommunicator()
    
    func addUser(username: String, email: String, passwordHash: String) async throws -> Int {
        let parameters: [String: Any] = ["method_name": "add_user", "params": ["username": username, "email": email, "password_hash": passwordHash]]
        let data = try await serverCommunicator.sendMethod(parameters: parameters)
        if let jsonResponse = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
           let result = jsonResponse["result"] as? [String: Any],
           let newUserId = result["new_user_id"] as? Int {
            return newUserId
        } else {
            throw NSError(domain: "CustomError", code: 100, userInfo: [NSLocalizedDescriptionKey: "Unexpected JSON format."])
        }
    }
    
    func verifyUser(username: String, passwordHash: String) async throws -> Int {
        let parameters: [String: Any] = ["method_name": "verify_user", "params": ["username": username, "password_hash": passwordHash]]
        let data = try await serverCommunicator.sendMethod(parameters: parameters)
        if let jsonResponse = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
           let result = jsonResponse["result"] as? [String: Any],
           let verifiedUserId = result["verified_user_id"] as? Int {
            return verifiedUserId
        } else {
            throw NSError(domain: "CustomError", code: 100, userInfo: [NSLocalizedDescriptionKey: "Unexpected JSON format."])
        }
    }

    func postImage(userId: Int, image: UIImage, caption: String) async throws -> Int {
        guard let imageData = image.jpegData(compressionQuality: 0.5) else {
            throw NSError(domain: "ImageError", code: 200, userInfo: [NSLocalizedDescriptionKey: "Image compression failed."])
        }
        let base64ImageString = imageData.base64EncodedString()
        let parameters: [String: Any] = [
            "method_name": "post_image",
            "params": [
                "user_id": userId,
                "image_data": base64ImageString,
                "caption": caption
            ]
        ]
        let data = try await serverCommunicator.sendMethod(parameters: parameters)
        if let jsonResponse = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
           let result = jsonResponse["result"] as? [String: Any],
           let newImageId = result["new_image_id"] as? Int {
            return newImageId
        } else {
            throw NSError(domain: "CustomError", code: 100, userInfo: [NSLocalizedDescriptionKey: "Unexpected JSON format."])
        }
    }

    func setTagsToImage(imageId: Int, tags: Set<Tag>) async throws -> Bool {
        let tagsWithInterestArray = tags.map { ["tag_id": $0.tagId, "interest_level": 1.0] }
        let parameters: [String: Any] = [
            "method_name": "set_tags_to_image",
            "params": ["image_id": imageId, "tags_with_interest": tagsWithInterestArray]
        ]
        let data = try await serverCommunicator.sendMethod(parameters: parameters)
        if let jsonResponse = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
           let result = jsonResponse["result"] as? [String: Any]{
            return true
        } else {
            throw NSError(domain: "CustomError", code: 101, userInfo: [NSLocalizedDescriptionKey: "Failed to set tags to image."])
        }
    }

    func toggleLikeOnImage(userId: Int, imageId: Int) async throws -> Void {
        let parameters: [String: Any] = ["method_name": "toggle_like_on_image", "params": ["user_id": userId, "image_id": imageId]]
        _ = try await serverCommunicator.sendMethod(parameters: parameters)
        // No need for further processing if no return value is expected
    }

    func toggleSaveOnImage(userId: Int, imageId: Int) async throws -> Void {
        let parameters: [String: Any] = ["method_name": "toggle_save_on_image", "params": ["user_id": userId, "image_id": imageId]]
        _ = try await serverCommunicator.sendMethod(parameters: parameters)
        // No need for further processing if no return value is expected
    }

    //###GETTERS###//

    func getTagsFromImage(imageId: Int) async throws -> [Tag] {
        let parameters: [String: Any] = ["method_name": "get_image_tags", "params": ["image_id": imageId]]
        let data = try await serverCommunicator.sendMethod(parameters: parameters)
        if let jsonResponse = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
           let result = jsonResponse["result"] as? [String: Any],
           let tagDicts = result["tags"] as? [[String: Any]] {
            return tagDicts.compactMap { dict in
                guard let tagId = dict["tag_id"] as? Int else { return nil }
                return TagManager().getTagById(tagId: tagId) // Assuming .top is a placeholder
            }
        } else {
            throw NSError(domain: "CustomError", code: 100, userInfo: [NSLocalizedDescriptionKey: "Unexpected JSON format."])
        }
    }

    func hasUserLikedImage(userId: Int, imageId: Int) async throws -> Bool {
        let parameters: [String: Any] = ["method_name": "has_user_liked_image", "params": ["user_id": userId, "image_id": imageId]]
        let data = try await serverCommunicator.sendMethod(parameters: parameters)
        if let jsonResponse = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
           let result = jsonResponse["result"] as? [String: Any],
           let hasLiked = result["has_liked"] as? String {
            return (hasLiked == "True")
        } else {
            throw NSError(domain: "CustomError poopy", code: 100, userInfo: [NSLocalizedDescriptionKey: "Unexpected JSON format."])
        }
    }

    func getLikesOnImage(imageId: Int) async throws -> Int {
        let parameters: [String: Any] = ["method_name": "get_image_like_count", "params": ["image_id": imageId]]
        let data = try await serverCommunicator.sendMethod(parameters: parameters)
        if let jsonResponse = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
           let result = jsonResponse["result"] as? [String: Any],
           let likeCount = result["like_count"] as? Int {
            return likeCount
        } else {
            throw NSError(domain: "CustomError", code: 100, userInfo: [NSLocalizedDescriptionKey: "Unexpected JSON format."])
        }
    }

    func hasUserSavedImage(userId: Int, imageId: Int) async throws -> Bool {
        let parameters: [String: Any] = ["method_name": "has_user_saved_image", "params": ["user_id": userId, "image_id": imageId]]
        let data = try await serverCommunicator.sendMethod(parameters: parameters)
        if let jsonResponse = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
           let result = jsonResponse["result"] as? [String: Any],
           let hasSaved = result["has_saved"] as? String {
            return (hasSaved == "True")
        } else {
            throw NSError(domain: "CustomError", code: 100, userInfo: [NSLocalizedDescriptionKey: "Unexpected JSON format."])
        }
    }

    func retrieveImage(imageId: Int) async throws -> (UIImage, String) {
        let parameters: [String: Any] = ["method_name": "retrieve_image", "params": ["image_id": imageId]]
        let data = try await serverCommunicator.sendMethod(parameters: parameters)
        if let jsonResponse = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]{
            if let result = jsonResponse["result"] as? [String: Any],
               let imageData = result["image_data"] as? [String: Any],
               let imageDataString = imageData["image_data"] as? String, let imageCaption = imageData["caption"] as? String{
                if let imageData = Data(base64Encoded: imageDataString),let image = UIImage(data: imageData) {
                return (image, imageCaption)
                    
                }
                else{
                    throw NSError(domain: "ImageConversionError", code: 200, userInfo: [NSLocalizedDescriptionKey: "Failed to convert image data."])
                }
            }
            else{
                throw NSError(domain: "ImageConversionError", code: 200, userInfo: [NSLocalizedDescriptionKey: "Failed to convert image data."])
            }
        } else {
            throw NSError(domain: "ImageConversionError", code: 200, userInfo: [NSLocalizedDescriptionKey: "Failed to convert image data."])
        }
    }


    func getImagesForUser(userId: Int) async throws -> ([Int], [UIImage], [String]) {
        let imageIds = try await getUserImageIds(userId: userId)
        var images = [UIImage]()
        var captions = [String]()

        for imageId in imageIds {
            let (image, caption) = try await retrieveImage(imageId: imageId)
            images.append(image)
            captions.append(caption)
        }

        return (imageIds, images, captions)
    }
    
    func getSavedImagesByTag(userId: Int, tag: Tag) async throws -> ([Int], [UIImage], [String]) {
        let imageIds = try await getUserSavedImageIdsByTag(userId: userId, tag: tag)
        var images = [UIImage]()
        var captions = [String]()

        for imageId in imageIds {
            let (image, caption) = try await retrieveImage(imageId: imageId)
            images.append(image)
            captions.append(caption)
        }

        return (imageIds, images, captions)
    }

    func getUserImageIds(userId: Int) async throws -> [Int] {
        let parameters: [String: Any] = [
            "method_name": "get_user_images",
            "params": ["user_id": userId]
        ]

        let data = try await serverCommunicator.sendMethod(parameters: parameters)
        if let jsonResponse = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
           let result = jsonResponse["result"] as? [String: Any],
           let imageIds = result["image_ids"] as? [Int] {
            return imageIds
        } else {
            throw NSError(domain: "CustomError", code: 100, userInfo: [NSLocalizedDescriptionKey: "Unexpected JSON format."])
        }
    }

    func getUserSavedImageIdsByTag(userId: Int, tag: Tag) async throws -> [Int] {
        let parameters: [String: Any] = [
            "method_name": "get_user_saved_image_ids_by_tag",
            "params": ["user_id": userId, "tag_id": tag.tagId]
        ]

        let data = try await serverCommunicator.sendMethod(parameters: parameters)
        if let jsonResponse = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
           let result = jsonResponse["result"] as? [String: Any],
           let imageIds = result["image_ids"] as? [Int] {
            return imageIds
        } else {
            throw NSError(domain: "CustomError", code: 100, userInfo: [NSLocalizedDescriptionKey: "Unexpected JSON format."])
        }
    }
}

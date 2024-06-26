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
    
    func verifyUser(email: String, passwordHash: String) async throws -> Int {
        let parameters: [String: Any] = ["method_name": "verify_user", "params": ["email": email, "password_hash": passwordHash]]
        let data = try await serverCommunicator.sendMethod(parameters: parameters)
        if let jsonResponse = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
           let result = jsonResponse["result"] as? [String: Any],
           let verifiedUserId = result["verified_user_id"] as? Int {
            return verifiedUserId
        } else {
            throw NSError(domain: "CustomError", code: 100, userInfo: [NSLocalizedDescriptionKey: "Unexpected JSON format."])
        }
    }

    func postImage(userId: Int, image: UIImage, caption: String, price: String) async throws -> Int {
        guard let imageData = image.jpegData(compressionQuality: 0.5) else {
            throw NSError(domain: "ImageError", code: 200, userInfo: [NSLocalizedDescriptionKey: "Image compression failed."])
        }
        let base64ImageString = imageData.base64EncodedString()
        let parameters: [String: Any] = [
            "method_name": "post_image",
            "params": [
                "user_id": userId,
                "image_data": base64ImageString,
                "caption": caption,
                "price": price
            ]
        ]
        let data = try await serverCommunicator.sendMethod(parameters: parameters)
        if let jsonResponse = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
           let result = jsonResponse["result"] as? [String: Any],
           let newimageId = result["new_image_id"] as? Int {
            return newimageId
        } else {
            throw NSError(domain: "CustomError", code: 100, userInfo: [NSLocalizedDescriptionKey: "Unexpected JSON format."])
        }
    }
    
    func uploadProfilePicture(userId: Int, image: UIImage) async throws -> Void {
        guard let imageData = image.jpegData(compressionQuality: 0.5) else {
            throw NSError(domain: "ImageError", code: 200, userInfo: [NSLocalizedDescriptionKey: "Image compression failed."])
        }
        
        let base64ImageString = imageData.base64EncodedString()
        let parameters: [String: Any] = [
            "method_name": "upload_profile_picture",
            "params": [
                "user_id": userId,
                "image_data": base64ImageString
            ]
        ]
        let data = try await serverCommunicator.sendMethod(parameters: parameters)
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
        let saved = try await hasUserSavedImage(userId: userId, imageId: imageId)
        // No need for further processing if no return value is expected
    }
    
    func addBid(sellerId: Int, buyerId: Int, imageId: Int, messageText: String, successful: Bool, isSellerResponse: Bool) async throws -> Int {
        let parameters: [String: Any] = [
            "method_name": "add_bid",
            "params": ["seller_id": sellerId, "buyer_id": buyerId, "image_id": imageId, "message_text": messageText, "successful": (successful ? "True" : "False"), "is_seller_response": (isSellerResponse ? "True" : "False")]
        ]
        let data = try await serverCommunicator.sendMethod(parameters: parameters)
        if let jsonResponse = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
           let result = jsonResponse["result"] as? [String: Any],
           let bidId = result["bid_id"] as? Int{
            return bidId
        } else {
            throw NSError(domain: "CustomError", code: 100, userInfo: [NSLocalizedDescriptionKey: "Failed to add bid."])
        }
    }
    
    //###GETTERS/UTILITY###//
    
    func getUsername(userId: Int) async throws -> String {
        let parameters: [String: Any] = ["method_name": "get_username", "params": ["user_id": userId]]
        let data = try await serverCommunicator.sendMethod(parameters: parameters)
        if let jsonResponse = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
           let result = jsonResponse["result"] as? [String: Any],
           let username = result["username"] as? String {
            return (username)
        } else {
            return ""
            throw NSError(domain: "CustomError", code: 100, userInfo: [NSLocalizedDescriptionKey: "Unexpected JSON format."])
        }
    }

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
    
    func createBlankImage() -> UIImage? {
        let size = CGSize(width: 200, height: 300)
        let renderer = UIGraphicsImageRenderer(size: size)
        let img = renderer.image { ctx in
            UIColor.white.setFill()
            ctx.fill(CGRect(origin: .zero, size: size))
        }
        return img
    }

    func retrieveImage(imageId: Int) async throws -> (Int, UIImage, Double, String) {
        let parameters: [String: Any] = ["method_name": "retrieve_image", "params": ["image_id": imageId]]
        let data = try await serverCommunicator.sendMethod(parameters: parameters)
        if let jsonResponse = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]{
            if let result = jsonResponse["result"] as? [String: Any], let imageData = result["image_data"] as? [String: Any]{
                  if let imageDataString = imageData["image_data"] as? String, let imageCaption = imageData["caption"] as? String, let userId = imageData["user_id"] as? Int, let userId = imageData["user_id"] as? Int{
                      var imagePrice = -1.0
                      if let tempPrice = imageData["price"] as? Double {
                          imagePrice = tempPrice
                      }
                   if let imageData = Data(base64Encoded: imageDataString), let image = UIImage(data: imageData) {
                       return (userId, image, imagePrice, imageCaption)
                       
                   }
                   else{
                       return (-1, createBlankImage()!, -1, "Unable to Load")
                       throw NSError(domain: "ImageConversionError", code: 200, userInfo: [NSLocalizedDescriptionKey: "Failed to convert image data."])
                   }
               } else{
                   return (-1, createBlankImage()!, -1, "Unable to Load")

                   throw NSError(domain: "ImageConversionError", code: 200, userInfo: [NSLocalizedDescriptionKey: "Failed to convert image data."])
               }
            }
            else{
                return (-1, createBlankImage()!, -1, "Unable to Load")

                throw NSError(domain: "ImageConversionError", code: 200, userInfo: [NSLocalizedDescriptionKey: "Failed to convert image data."])
            }
        } else {
            return (-1, createBlankImage()!, -1, "Unable to Load")

            throw NSError(domain: "ImageConversionError", code: 200, userInfo: [NSLocalizedDescriptionKey: "Failed to convert image data."])
        }
    }
    
    func retrieveProfilePicture(userId: Int) async throws -> UIImage {
        let parameters: [String: Any] = ["method_name": "retrieve_profile_picture", "params": ["user_id": userId]]
        let data = try await serverCommunicator.sendMethod(parameters: parameters)
        if let jsonResponse = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]{
            if let result = jsonResponse["result"] as? [String: Any],
               let imageData = result["image_data"] as? [String: Any],
               let imageDataString = imageData["image_data"] as? String{
                if let imageData = Data(base64Encoded: imageDataString), let image = UIImage(data: imageData) {
                return image
                    
                }
                else{
                    
                    return UIImage(systemName: "person.crop.circle.fill") ?? UIImage() // Fallback to an empty UIImage if the system image is not found
                }
            }
            else{
                return UIImage(systemName: "person.crop.circle.fill") ?? UIImage() // Fallback to an empty UIImage if the system image is not found
            }
        } else {
            return UIImage(systemName: "person.crop.circle.fill") ?? UIImage() // Fallback to an empty UIImage if the system image is not found
        }
    }
    func getImagesForUser(userId: Int) async throws -> ([Int], [UIImage], [String]) {
        let imageIds = try await getUserImageIds(userId: userId)
        var images = [UIImage]()
        var captions = [String]()

        for imageId in imageIds {
            let (userId, image, price, caption) = try await retrieveImage(imageId: imageId)
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
            let (userId, image, price, caption) = try await retrieveImage(imageId: imageId)
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
    
    func generateUserFeed(userId: Int, limit: Int) async throws -> [Int] {
        let parameters: [String: Any] = [
            "method_name": "generate_user_feed",
            "params": ["user_id": userId, "limit": limit]
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
    
    func doesBidExist(buyerId: Int, imageId: Int) async throws -> Bool {
        let parameters: [String: Any] = ["method_name": "does_bid_exist", "params": ["buyer_id": buyerId, "image_id": imageId]]
        let data = try await serverCommunicator.sendMethod(parameters: parameters)
        if let jsonResponse = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
           let result = jsonResponse["result"] as? [String: Any],
           let doesExist = result["does_exist"] as? String {
            return (doesExist == "True")
        } else {
            throw NSError(domain: "CustomError poopy", code: 100, userInfo: [NSLocalizedDescriptionKey: "Unexpected JSON format."])
        }
    }
    
    func getBidInfo(bidId: Int) async throws -> (Int, Int, Int, String, Bool, Bool, Bool) {
        let parameters: [String: Any] = [
            "method_name": "get_bid_info",
            "params": ["bid_id": bidId]
        ]
        
        let data = try await serverCommunicator.sendMethod(parameters: parameters)
        if let jsonResponse = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
           let result = jsonResponse["result"] as? [String: Any],
           let bidInfo = result["bid_info"] as? [String: Any], let buyerId = bidInfo["buyer_id"] as? Int, let sellerId = bidInfo["seller_id"] as? Int, let imageId = bidInfo["image_id"] as? Int, let messageText = bidInfo["message_text"] as? String, let seenBySeller = bidInfo["seen_by_seller"] as? Int, let bidSuccessful = bidInfo["successful"] as? Int, let bidIsSellerResponse = bidInfo["is_seller_repsonse"] as? Int{
            return (buyerId, sellerId, imageId, messageText, seenBySeller == 1, bidSuccessful == 1, bidIsSellerResponse == 1)
            
        } else {
            throw NSError(domain: "CustomError", code: 100, userInfo: [NSLocalizedDescriptionKey: "Unexpected JSON format."])
        }
    }
    
    func getImageBids(imageId: Int) async throws -> [Int] {
        let parameters: [String: Any] = [
            "method_name": "get_image_bids",
            "params": ["image_id": imageId]
        ]
        
        let data = try await serverCommunicator.sendMethod(parameters: parameters)
        if let jsonResponse = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
           let result = jsonResponse["result"] as? [String:Any],
           let messageIds = result["message_ids"] as? [Int] {
            for messageId in messageIds{
            }
            return []
        } else {
            throw NSError(domain: "CustomError", code: 100, userInfo: [NSLocalizedDescriptionKey: "Unexpected JSON format."])
        }
    }

    func getSellerBidIds(sellerId: Int) async throws -> [Int] {
        let parameters: [String: Any] = [
            "method_name": "get_seller_bid_ids",
            "params": ["seller_id": sellerId]
        ]

        let data = try await serverCommunicator.sendMethod(parameters: parameters)
        if let jsonResponse = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
           let result = jsonResponse["result"] as? [String: Any],
           let bidIds = result["bid_ids"] as? [Int] {
            return bidIds
        } else {
            throw NSError(domain: "CustomError", code: 100, userInfo: [NSLocalizedDescriptionKey: "Unexpected JSON format."])
        }
    }

    func getBuyerBidIds(buyerId: Int) async throws -> [Int] {
        let parameters: [String: Any] = [
            "method_name": "get_buyer_bid_ids",
            "params": ["buyer_id": buyerId]
        ]

        let data = try await serverCommunicator.sendMethod(parameters: parameters)
        if let jsonResponse = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
           let result = jsonResponse["result"] as? [String: Any],
           let bidIds = result["bid_ids"] as? [Int] {
            return bidIds
        } else {
            throw NSError(domain: "CustomError", code: 100, userInfo: [NSLocalizedDescriptionKey: "Unexpected JSON format."])
        }
    }
    
    func getBuyerBidInfo(buyerId: Int) async throws -> ([Int], [Int], [Int], [Int], [String], [Bool], [Bool], [Bool]) {
        let bidIds = try await getBuyerBidIds(buyerId: buyerId)
        var buyerIds = [] as [Int]
        var sellerIds = [] as [Int]
        var imageIds = [] as [Int]
        var messageTexts = [] as [String]
        var seenBySellers = [] as [Bool]
        var successfulBids = [] as [Bool]
        var isSellerResponses = [] as [Bool]
        for bidId in bidIds{
            let (newBuyerId, newSellerId, newImageId, newMessageText, newSeenBySeller, newIsSuccessful, newIsSellerResponse) = try await ServerCommands().getBidInfo(bidId: bidId)
            buyerIds.append(newBuyerId)
            sellerIds.append(newSellerId)
            imageIds.append(newImageId)
            messageTexts.append(newMessageText)
            seenBySellers.append(newSeenBySeller)
            successfulBids.append(newIsSuccessful)
            isSellerResponses.append(newIsSellerResponse)
        }
        return (bidIds, buyerIds, sellerIds, imageIds, messageTexts, seenBySellers, successfulBids, isSellerResponses)
    }
    
    func getSellerBidInfo(sellerId: Int) async throws -> ([Int], [Int], [Int], [Int], [String], [Bool], [Bool], [Bool]) {
        let bidIds = try await getSellerBidIds(sellerId: sellerId)
        var buyerIds = [] as [Int]
        var sellerIds = [] as [Int]
        var imageIds = [] as [Int]
        var messageTexts = [] as [String]
        var seenBySellers = [] as [Bool]
        var successfulBids = [] as [Bool]
        var isSellerResponses = [] as [Bool]
        for bidId in bidIds{
            let (newBuyerId, newSellerId, newImageId, newMessageText, newSeenBySeller, newIsSuccessful, newIsSellerResponse) = try await ServerCommands().getBidInfo(bidId: bidId)
            buyerIds.append(newBuyerId)
            sellerIds.append(newSellerId)
            imageIds.append(newImageId)
            messageTexts.append(newMessageText)
            seenBySellers.append(newSeenBySeller)
            successfulBids.append(newIsSuccessful)
            isSellerResponses.append(newIsSellerResponse)
        }
        return (bidIds, buyerIds, sellerIds, imageIds, messageTexts, seenBySellers, successfulBids, isSellerResponses)
    }
    
    func countUnseenBidMessages(userId: Int) async throws -> Int {
        let parameters: [String: Any] = ["method_name": "count_unseen_bid_messages", "params": ["user_id": userId]]
        let data = try await serverCommunicator.sendMethod(parameters: parameters)
        if let jsonResponse = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
           let result = jsonResponse["result"] as? [String: Any],
           let hasLiked = result["unseen_count"] as? Int {
             return (hasLiked)
        } else {
            throw NSError(domain: "CustomError poopy", code: 100, userInfo: [NSLocalizedDescriptionKey: "Unexpected JSON format."])
        }
    }
    
    func markBidSuccessful(bidId: Int) async throws -> Void {
        let parameters: [String: Any] = [
            "method_name": "mark_bid_successful",
            "params": ["bid_id": bidId]
        ]
        _ = try await serverCommunicator.sendMethod(parameters: parameters)
    }
    
    func markBidAsSeen(bidId: Int, sellerId: Int) async throws -> Void {
        let parameters: [String: Any] = [
            "method_name": "mark_bid_as_seen",
            "params": ["bid_id": bidId, "seller_id": sellerId]
        ]
        _ = try await serverCommunicator.sendMethod(parameters: parameters)
    }
    
    func markBidAsUnseen(bidId: Int, sellerId: Int) async throws -> Void {
        let parameters: [String: Any] = [
            "method_name": "mark_bid_as_unseen",
            "params": ["bid_id": bidId, "seller_id": sellerId]
        ]
        _ = try await serverCommunicator.sendMethod(parameters: parameters)
    }
    
    func deleteBid(bidId: Int) async throws -> Void {
        let parameters: [String: Any] = [
            "method_name": "delete_bid",
            "params": ["bid_id": bidId]
        ]
        _ = try await serverCommunicator.sendMethod(parameters: parameters)
    }
    
    func searchTags(searchTerm: String) async throws -> [Int] {
        let parameters: [String: Any] = [
            "method_name": "search_tags",
            "params": ["search_term": searchTerm]
        ]

        let data = try await serverCommunicator.sendMethod(parameters: parameters)
        if let jsonResponse = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
           let result = jsonResponse["result"] as? [String: Any],
           let imageIds = result["recommended_tags"] as? [Int] {
            return imageIds
        } else {
            throw NSError(domain: "CustomError", code: 100, userInfo: [NSLocalizedDescriptionKey: "Unexpected JSON format."])
        }
    }
    
    func getImagesForTag(tagId: Int) async throws -> [Int] {
        let parameters: [String: Any] = [
            "method_name": "get_images_for_tag",
            "params": ["tag_id": tagId]
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
    
    func getFollowersCount(userId: Int) async throws -> Int {
            let parameters: [String: Any] = [
                "method_name": "get_followers_count",
                "params": ["user_id": userId]
            ]

            let data = try await serverCommunicator.sendMethod(parameters: parameters)
            if let jsonResponse = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
               let result = jsonResponse["result"] as? [String: Any],
               let followersCount = result["followers_count"] as? Int {
                return followersCount
            } else {
                throw NSError(domain: "CustomError", code: 100, userInfo: [NSLocalizedDescriptionKey: "Unexpected JSON format."])
            }
        }
    
    func toggleFollow(followerId: Int, followedId: Int) async throws -> Void {
        let parameters: [String: Any] = ["method_name": "toggle_follow", "params": ["follower_id": followerId, "followed_id": followedId]]
        try await serverCommunicator.sendMethod(parameters: parameters)
        // No need for further processing if no return value is expected
    }

    func checkIfUserFollows(followerId: Int, followedId: Int) async throws -> Bool {
        let parameters: [String: Any] = ["method_name": "check_if_user_follows", "params": ["follower_id": followerId, "followed_id": followedId]]


        let data = try await serverCommunicator.sendMethod(parameters: parameters)
        if let jsonResponse = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
           let result = jsonResponse["result"] as? [String: Any],
           let follows = result["follows"] as? String {
            return follows == "True"
        } else {
            throw NSError(domain: "CustomError", code: 100, userInfo: [NSLocalizedDescriptionKey: "Unexpected JSON format."])
        }
    }
}

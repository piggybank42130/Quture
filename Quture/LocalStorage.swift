//
//  LocalStorage.swift
//  Quture
//
//  Created by Rohan Tan Bhowmik on 3/9/24.
//

import Foundation

struct LocalStorage {
    func saveUserId(number: Int) {
        // Find the document directory of the app
        if let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            let fileURL = documentDirectory.appendingPathComponent("userId.txt")
            
            // Convert number to String
            let numberString = "\(number)"
            
            // Write the string to a file
            do {
                try numberString.write(to: fileURL, atomically: true, encoding: .utf8)
                print("Number saved successfully")
            } catch {
                print("Failed to save number: \(error)")
            }
        }
    }
    
    func getUserId() -> Int {
        // Find the document directory of the app
        if let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            let fileURL = documentDirectory.appendingPathComponent("userId.txt")
            
            // Read the content of the file
            do {
                let numberString = try String(contentsOf: fileURL, encoding: .utf8)
                return 1//Int(numberString) ?? -1
            } catch {
                print("Failed to read number: \(error)")
                return -1
            }
        }
        return -1
    }
    
    func needToLogin() -> Bool{
        return getUserId() == -1
    }
    
    func logout() -> Void{
        saveUserId(number: -1)
    }
}

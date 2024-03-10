//
//  LocalStorage.swift
//  Quture
//
//  Created by Rohan Tan Bhowmik on 3/9/24.
//

import Foundation

struct LocalStorage {
    func saveNumber(number: Int, to fileName: String) {
        // Find the document directory of the app
        if let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            let fileURL = documentDirectory.appendingPathComponent(fileName)
            
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
    
    func getNumber(from fileName: String) -> Int? {
        // Find the document directory of the app
        if let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            let fileURL = documentDirectory.appendingPathComponent(fileName)
            
            // Read the content of the file
            do {
                let numberString = try String(contentsOf: fileURL, encoding: .utf8)
                return Int(numberString)
            } catch {
                print("Failed to read number: \(error)")
            }
        }
        return nil
    }
}

//
//  SharedNotificationsModel.swift
//  Quture
//
//  Created by Gabe on 3/10/24.
//

import Combine
import Dispatch

class BidNotificationsModel: ObservableObject{
    @Published var notifications: [String] = []
    
    func addNotification(_ notification: String) {
        DispatchQueue.main.async{
            self.notifications.append(notification)
        }
    }
}
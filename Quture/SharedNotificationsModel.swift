//
//  SharedNotificationsModel.swift
//  Quture
//
//  Created by Gabe on 3/10/24.
//

import Combine

class BidNotificationsModel: ObservableObject{
    @Published var notifications: [String] = []
    
    func addNotification(_ notification: String) {
        notifications.append(notification)
    }
}

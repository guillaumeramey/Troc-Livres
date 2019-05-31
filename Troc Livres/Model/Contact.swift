//
//  Contact.swift
//  Troc Livres
//
//  Created by Guillaume Ramey on 27/05/2019.
//  Copyright © 2019 Guillaume Ramey. All rights reserved.
//

import Foundation
import Firebase

class Contact {
    let uid: String
    let name: String
    let timestamp: TimeInterval?
    var unread: Bool

    init(with user: User) {
        self.uid = user.uid
        self.name = user.name
        self.timestamp = nil
        self.unread = false
    }

    init?(from snapshot: DataSnapshot){
        guard
            let value = snapshot.value as? [String: Any],
            let name = value["name"] as? String,
            let unread = value["unread"] as? Bool,
            let timestamp = value["timestamp"] as? TimeInterval
            else {
                return nil
        }

        self.uid = snapshot.key
        self.name = name
        self.unread = unread
        self.timestamp = timestamp
    }

    // Mark the conversation as read
    func markAsRead() {
        unread = false
        let path = "\(Session.user.uid)/contacts/\(uid)"
        Constants.Firebase.userRef.child(path).updateChildValues(["unread": false]) { (error, reference) in
            guard error == nil else { return }
        }
    }
}

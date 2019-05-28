//
//  Chat.swift
//  Troc Livres
//
//  Created by Guillaume Ramey on 26/05/2019.
//  Copyright © 2019 Guillaume Ramey. All rights reserved.
//

import Foundation
import Firebase

class Chat {
    let key: String
    var messages = [Message]()

    init?(fromKey key: String) {
        self.key = key
        Constants.Firebase.chatRef.child(key).observeSingleEvent(of: .value, with: { snapshot in
            if let message = Message(from: snapshot) {
                self.messages.append(message)
            }
        })
    }

    func message(_ text: String) {
        let message = [
            "text": text,
            "sender": Session.user.name,
            "timestamp": ServerValue.timestamp()
            ] as [String : Any]
        Constants.Firebase.chatRef.child(key).childByAutoId().setValue(message)
    }
}

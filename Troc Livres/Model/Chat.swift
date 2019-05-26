//
//  Chat.swift
//  Troc Livres
//
//  Created by Guillaume Ramey on 26/05/2019.
//  Copyright © 2019 Guillaume Ramey. All rights reserved.
//

import Foundation
import Firebase

struct Chat {
    let key: String
    var messages = [Message]()

    init?(from snapshot: DataSnapshot){
        self.key = snapshot.key

        // Get the chat messages
        for snapshotChild in snapshot.children {
            if let message = Message(from: snapshotChild as! DataSnapshot) {
                self.messages.append(message)
            }
        }
    }
}

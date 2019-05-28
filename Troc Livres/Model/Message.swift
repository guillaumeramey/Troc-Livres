//
//  Message.swift
//  Troc Livres
//
//  Created by Guillaume Ramey on 26/05/2019.
//  Copyright © 2019 Guillaume Ramey. All rights reserved.
//

import Foundation
import Firebase

struct Message {
    let sender: String
    let text: String
    let timestamp: Date

    init?(from snapshot: DataSnapshot){
        guard
            let value = snapshot.value as? [String: Any],
            let sender = value["sender"] as? String,
            let text = value["text"] as? String,
            let timestamp = value["timestamp"] as? TimeInterval
            else {
                return nil
        }

        self.sender = sender
        self.text = text
        self.timestamp = Date(timeIntervalSince1970: timestamp/1000)
    }
}

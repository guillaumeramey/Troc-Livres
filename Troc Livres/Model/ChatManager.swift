//
//  ChatManager.swift
//  Troc Livres
//
//  Created by Guillaume Ramey on 26/05/2019.
//  Copyright © 2019 Guillaume Ramey. All rights reserved.
//

import Foundation
import Firebase

struct ChatManager {

    static func getUserChats(completion: @escaping (_ chats: [Chat]) -> Void) {
        var chats = [Chat]()
        Constants.Firebase.chatRef.observeSingleEvent(of: .value, with: { snapshot in
            for snapshotChild in snapshot.children {
                if let chat = Chat(from: snapshotChild as! DataSnapshot) {
                    chats.append(chat)
                }
            }
            completion(chats)
        })
    }
}

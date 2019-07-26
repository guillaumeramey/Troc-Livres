//
//  Chat.swift
//  Troc Livres
//
//  Created by Guillaume Ramey on 27/05/2019.
//  Copyright © 2019 Guillaume Ramey. All rights reserved.
//

import Foundation
import Firebase

class Chat: Equatable {
    let id: String
    let user: User
    let timestamp: Timestamp?
    var unread: Bool
    var messages: [Message]?
    
    init(from document: DocumentSnapshot) {
        id = document.documentID
        let data = document.get(Persist.uid) as? [String: Any]
        let uid = data?["uid"] as? String ?? "Erreur UID"
        let name = data?["name"] as? String ?? "Erreur nom"
        let fcmToken = data?["fcmToken"] as? String ?? "Erreur token"
        user = User(uid: uid, name: name, fcmToken: fcmToken)
        unread = data?["unread"] as? Bool ?? true
        timestamp = document.get("timestamp") as? Timestamp
    }

    init(id: String, with user: User) {
        self.user = user
        self.id = id
        timestamp = nil
        unread = true
    }
    
    static func == (lhs: Chat, rhs: Chat) -> Bool {
        return lhs.user.uid == rhs.user.uid
    }
}

extension Chat: ChatManagerInjectable {
    
    func newMessage(content: String, system: Bool = false, completion: @escaping (Bool) -> Void) {
        chatManager.newMessage(in: self, content: content, system: system, completion: { error in
            completion(error == nil)
        })
    }
    
    func getMessages(completion: @escaping (Bool) -> Void) {
        chatManager.getMessages(in: self) { messages in
            self.messages = messages
            completion(true)
        }
    }
    
    func markAsRead() {
        chatManager.markAsRead(self)
        unread = false
    }
    
    func leave() {
        FirebaseManager.leaveChat()
    }
}

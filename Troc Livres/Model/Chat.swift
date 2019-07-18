//
//  Chat.swift
//  Troc Livres
//
//  Created by Guillaume Ramey on 27/05/2019.
//  Copyright © 2019 Guillaume Ramey. All rights reserved.
//

import Foundation
import Firebase

class Chat {
    let id: String
    let uid: String
    let name: String
    let fcmToken: String
    let timestamp: Timestamp?
    let unread: Bool
    var messages: [Message]?

    init(from document: DocumentSnapshot) {
        id = document.documentID

        let data = document.get(Persist.uid) as? [String: Any]
        uid = data?["uid"] as? String ?? "Erreur UID"
        name = data?["name"] as? String ?? "Erreur nom"
        fcmToken = data?["fcmToken"] as? String ?? "Erreur token"
        unread = data?["unread"] as? Bool ?? true
        timestamp = document.get("timestamp") as? Timestamp
    }

    init(id: String, with user: User) {
        self.id = id
        self.uid = user.uid
        self.name = user.name
        self.fcmToken = user.fcmToken
        timestamp = nil
        unread = true
    }
    
    func getMessages(completion: @escaping (Bool) -> Void) {
        ChatManager.getMessages(in: self) { messages in
            self.messages = messages
            completion(true)
        }
    }
    
    func sendMessage(content: String, system: Bool = false, completion: @escaping (Bool) -> Void) {
        ChatManager.sendMessage(in: self, content: content, system: system, completion: { error in
            completion(error == nil)
        })
    }
    
    func markAsRead() {
        ChatManager.markChatAsRead(id: id)
    }
    
    func leave() {
        ChatManager.leaveChat()
    }
}

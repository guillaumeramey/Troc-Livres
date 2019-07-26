//
//  Chat.swift
//  Troc Livres
//
//  Created by Guillaume Ramey on 27/05/2019.
//  Copyright © 2019 Guillaume Ramey. All rights reserved.
//

import Foundation
import Firebase

class Chat: Equatable, DataManagerInjectable {
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
    
    // MARK: - Methods
    
    static func == (lhs: Chat, rhs: Chat) -> Bool {
        return lhs.user.uid == rhs.user.uid
    }

    func newMessage(content: String, system: Bool = false, completion: @escaping (Bool) -> Void) {
        dataManager.newMessage(in: self, content: content, system: system, completion: { error in
            completion(error == nil)
        })
    }
    
    func getMessages(completion: @escaping (Bool) -> Void) {
        dataManager.getMessages(in: self) { messages in
            self.messages = messages
            completion(true)
        }
    }
    
    func markAsRead() {
        dataManager.markChatAsRead(self)
        unread = false
    }
    
    func leave() {
        FirebaseManager.leaveChat()
    }
}

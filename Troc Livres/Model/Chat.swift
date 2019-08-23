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
    var user: User
    var timestamp: Timestamp
    var unread: Bool
    var messages = [Message]()
    
    init(from document: DocumentSnapshot) {
        timestamp = document.get("timestamp") as! Timestamp
        let data = document.get(Persist.uid) as? [String: Any]
        let uid = data?["uid"] as? String ?? "UID Error"
        let name = data?["name"] as? String ?? "Name Error"
        user = User(uid: uid, name: name, fcmToken: "")
        unread = data?["unread"] as? Bool ?? true
    }

    init(with user: User) {
        self.user = user
        timestamp = Timestamp()
        unread = true
    }
}

extension Chat {
    
    func getUser() {
        DependencyInjection.shared.dataManager.getUser(uid: user.uid) { user in
            guard let user = user else { return }
            self.user = user
        }
    }
    
    func newMessage(content: String, system: Bool = false, completion: @escaping (Bool) -> Void) {
        DependencyInjection.shared.dataManager.newMessage(in: self, content: content, system: system, completion: { error in
            if error == nil {
                // send notification
                var title = system ?
                    NSLocalizedString("new trade with", comment: "") :
                    NSLocalizedString("message from", comment: "")
                title += currentUser.name
                NetworkManager().sendPushNotification(to: self.user.fcmToken, title: title, body: content)
            }
            completion(error == nil)
        })
    }
    
    func getMessages(completion: @escaping (Bool) -> Void) {
        DependencyInjection.shared.dataManager.getMessages(in: self) { messages in
            self.messages = messages
            completion(true)
        }
    }
    
    func markAsRead() {
        DependencyInjection.shared.dataManager.markAsRead(self)
        unread = false
    }
}

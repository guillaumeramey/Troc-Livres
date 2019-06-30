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
    let timestamp: Timestamp?
    let unread: Bool

    init(from document: DocumentSnapshot) {
        id = document.documentID

        let data = document.get(Persist.uid) as? [String: Any]
        uid = data?["uid"] as? String ?? "Erreur UID"
        name = data?["name"] as? String ?? "Inconnu"
        unread = data?["unread"] as? Bool ?? true

        timestamp = document.get("timestamp") as? Timestamp
    }

    init(id: String, with user: User) {
        self.id = id
        self.uid = user.uid
        self.name = user.name
        timestamp = nil
        unread = true
    }
}
